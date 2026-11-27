<%-- 봉인, 개봉 연출 재생: .play(3초) / 동작 줄이기 .still. 건너뛰기, Esc로 바로 끝. 개봉은 끝나면 첫 열람을 POST한다. --%>
<script>
  (function () {
    var layer = document.getElementById("sceneLayer");
    if (!layer) return;
    var stage = layer.querySelector(".scene"), timer = null, finished = false;
    var reduce = window.matchMedia && matchMedia("(prefers-reduced-motion: reduce)").matches;

    function layout(n) {
      var ls = stage.querySelectorAll(".letter"), spread = Math.min(140, 34 * (n - 1));
      for (var i = 0; i < ls.length; i++) {
        var el = ls[i]; el.hidden = i >= n; if (el.hidden) continue;
        var a = n > 1 ? -spread / 2 + spread * i / (n - 1) : 0, r = a * Math.PI / 180;
        el.style.setProperty("--x", (Math.sin(r) * 250).toFixed(1) + "%");
        el.style.setProperty("--y", (-(140 + Math.cos(r) * 200)).toFixed(1) + "%");
        el.style.setProperty("--r", (a / 5).toFixed(1) + "deg");
        el.style.setProperty("--d", (1.3 + i * .05).toFixed(2) + "s");
      }
    }
    function finish() {
      if (finished) return;
      finished = true;
      clearTimeout(timer);
      var form = document.getElementById("openForm");
      if (form) { form.submit(); return; }          // 개봉: 기록 후 다시 그린 열림 화면으로
      layer.remove();                               // 봉인: 층이 사라지고 아래 잠김 화면이 그대로 보인다
    }
    if (layer.dataset.letters) layout(Math.min(6, Number(layer.dataset.letters)));
    if (reduce) { stage.classList.add("still"); timer = setTimeout(finish, 1000); }
    else { stage.classList.add("play"); timer = setTimeout(finish, 3000); }
    var skip = layer.querySelector("[data-skip]");
    skip.addEventListener("click", finish);
    skip.focus();
    document.addEventListener("keydown", function (e) { if (e.key === "Escape") finish(); });
  })();
</script>
