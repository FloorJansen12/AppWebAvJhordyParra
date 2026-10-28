/* ============================================================
   PoliMusic · Reproductor del listado de canciones
   Un solo audio suena a la vez y el contador de reproducciones
   se actualiza por AJAX (SongPlay.ashx) sin recargar la página.
   ============================================================ */

(function () {
    "use strict";

    var rows = Array.prototype.slice.call(document.querySelectorAll("tr.track"));
    if (!rows.length) {
        return;
    }

    var masterVolume = 0.8;

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0) {
            return "0:00";
        }
        var total = Math.floor(seconds);
        var minutes = Math.floor(total / 60);
        var secs = total % 60;
        return minutes + ":" + (secs < 10 ? "0" : "") + secs;
    }

    function setFill(range, percent) {
        var value = Math.max(0, Math.min(100, percent));
        range.style.setProperty("--p", value + "%");
    }

    function registerPlay(row, idSong) {
        var cell = row.querySelector("[data-plays]");
        if (!cell || !idSong) {
            return;
        }
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "SongPlay.ashx?id=" + encodeURIComponent(idSong), true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4 || xhr.status !== 200) {
                return;
            }
            var value = parseInt(xhr.responseText, 10);
            if (isNaN(value) || value < 0) {
                return;
            }
            cell.textContent = value.toLocaleString("es-EC");
            cell.classList.add("is-bumped");
            window.setTimeout(function () {
                cell.classList.remove("is-bumped");
            }, 700);
        };
        try {
            xhr.send();
        } catch (error) {
            /* Si falla el contador, la reproducción continúa igual. */
        }
    }

    function pauseOthers(currentRow) {
        rows.forEach(function (row) {
            if (row === currentRow) {
                return;
            }
            var audio = row.querySelector("audio");
            if (audio && !audio.paused) {
                audio.pause();
            }
        });
    }

    function refreshMuteState() {
        var muted = false;
        for (var i = 0; i < rows.length; i++) {
            var audio = rows[i].querySelector("audio");
            if (audio) {
                muted = audio.muted;
                break;
            }
        }
        rows.forEach(function (row) {
            if (muted) {
                row.classList.add("is-muted");
            } else {
                row.classList.remove("is-muted");
            }
        });
    }

    rows.forEach(function (row) {
        var audio = row.querySelector("audio");
        var player = row.querySelector(".player");
        var playBtn = row.querySelector("[data-play]");
        var seek = row.querySelector(".seek");
        var current = row.querySelector("[data-cur]");
        var duration = row.querySelector("[data-dur]");
        var volume = row.querySelector(".vol");
        var muteBtn = row.querySelector("[data-mute]");
        var available = player && player.getAttribute("data-available") === "true";
        var counted = false;

        if (!audio || !playBtn || !seek || !available) {
            return;
        }

        audio.volume = masterVolume;

        playBtn.addEventListener("click", function () {
            if (audio.paused) {
                pauseOthers(row);
                var promise = audio.play();
                if (promise && typeof promise.catch === "function") {
                    promise.catch(function () {
                        /* El navegador puede bloquear la reproducción automática. */
                    });
                }
            } else {
                audio.pause();
            }
        });

        audio.addEventListener("play", function () {
            row.classList.add("is-playing");
            playBtn.setAttribute("aria-label", "Pausar canción");
            if (!counted) {
                counted = true;
                registerPlay(row, row.getAttribute("data-id"));
            }
        });

        audio.addEventListener("pause", function () {
            row.classList.remove("is-playing");
            playBtn.setAttribute("aria-label", "Reproducir canción");
        });

        audio.addEventListener("ended", function () {
            row.classList.remove("is-playing");
            playBtn.setAttribute("aria-label", "Reproducir canción");
            seek.value = 0;
            setFill(seek, 0);
            current.textContent = "0:00";
        });

        audio.addEventListener("loadedmetadata", function () {
            duration.textContent = formatTime(audio.duration);
        });

        audio.addEventListener("timeupdate", function () {
            current.textContent = formatTime(audio.currentTime);
            if (audio.duration && isFinite(audio.duration)) {
                var percent = (audio.currentTime / audio.duration) * 100;
                seek.value = percent;
                setFill(seek, percent);
            }
        });

        audio.addEventListener("error", function () {
            row.classList.add("is-unavailable");
            row.classList.remove("is-playing");
            playBtn.disabled = true;
            if (player) {
                player.setAttribute("data-available", "false");
            }
        });

        seek.addEventListener("input", function () {
            if (!audio.duration || !isFinite(audio.duration)) {
                return;
            }
            var percent = parseFloat(seek.value) || 0;
            audio.currentTime = (percent / 100) * audio.duration;
            setFill(seek, percent);
        });

        if (volume) {
            volume.value = masterVolume;
            setFill(volume, masterVolume * 100);

            volume.addEventListener("input", function () {
                masterVolume = parseFloat(volume.value) || 0;
                rows.forEach(function (other) {
                    var otherAudio = other.querySelector("audio");
                    var otherVolume = other.querySelector(".vol");
                    if (otherAudio) {
                        otherAudio.volume = masterVolume;
                        otherAudio.muted = masterVolume === 0;
                    }
                    if (otherVolume) {
                        otherVolume.value = masterVolume;
                        setFill(otherVolume, masterVolume * 100);
                    }
                });
                refreshMuteState();
            });
        }

        if (muteBtn) {
            muteBtn.addEventListener("click", function () {
                var muted = !audio.muted;
                rows.forEach(function (other) {
                    var otherAudio = other.querySelector("audio");
                    if (otherAudio) {
                        otherAudio.muted = muted;
                    }
                });
                refreshMuteState();
            });
        }
    });
})();
