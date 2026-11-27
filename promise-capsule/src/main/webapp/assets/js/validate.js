/* 폼 검사(브라우저 쪽). 서버도 같은 규칙으로 다시 검사한다.
 *
 *   <form data-validate novalidate onsubmit="return checkForm(this)">   검사할 폼
 *   <input data-v="required min:4 max:20 pattern:^[a-z0-9_]+$">   규칙(공백으로 나눔)
 *        email, same:#다른칸id, checked
 *   <div class="err" data-err hidden>이유</div>        같은 .field 안의 오류 문구
 *   <div data-summary data-template="...{0}..." hidden><p></p></div>  요약(선택)
 *   <textarea data-counter="#cnt" data-max="2000">     글자 수 표시
 * 글자 수는 서버와 같이 코드 포인트로 센다.
 */
(function () {
  function len(s) { return Array.from(s).length; }

  function check(input) {
    var rules = (input.dataset.v || "").split(/\s+/).filter(Boolean);
    var raw = input.type === "password" || "notrim" in input.dataset ? input.value : input.value.trim();
    for (var i = 0; i < rules.length; i++) {
      var r = rules[i], arg = r.indexOf(":") > 0 ? r.slice(r.indexOf(":") + 1) : "";
      if (r === "required" && raw === "") return false;
      if (r === "checked" && !input.checked) return false;
      if (raw === "") continue;                       // 빈 칸은 required만 본다
      if (r.indexOf("min:") === 0 && len(raw) < +arg) return false;
      if (r.indexOf("max:") === 0 && len(raw) > +arg) return false;
      if (r.indexOf("pattern:") === 0 && !new RegExp(arg).test(raw)) return false;
      if (r === "email" && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(raw)) return false;
      if (r.indexOf("same:") === 0) {
        var other = document.querySelector(arg);
        if (other && other.value !== input.value) return false;
      }
    }
    return true;
  }

  function show(input, ok) {
    var field = input.closest(".field") || input.parentElement;
    var err = field.querySelector("[data-err]");
    field.classList.toggle("invalid", !ok);
    if (ok) {
      input.removeAttribute("aria-invalid");
      if (err) err.hidden = true;
      if (input.dataset.changed) field.querySelectorAll("[data-srv-err]").forEach(function (s) { s.hidden = true; });
      var keep = (input.getAttribute("aria-describedby") || "").split(/\s+/).filter(function (id) {
        var el = id && document.getElementById(id);
        return el && !el.hidden && !el.hasAttribute("data-err") && !el.hasAttribute("data-srv-err");
      });
      if (keep.length) input.setAttribute("aria-describedby", keep.join(" ")); else input.removeAttribute("aria-describedby");
    } else {
      input.setAttribute("aria-invalid", "true");
      if (err) {
        if (!err.id) err.id = (input.id || input.name) + "-err";
        err.hidden = false;
        var ids = (input.getAttribute("aria-describedby") || "").split(/\s+/).filter(Boolean);
        if (ids.indexOf(err.id) < 0) ids.push(err.id);
        input.setAttribute("aria-describedby", ids.join(" "));
      }
    }
  }

  // 제출 검사: 폼에서 onsubmit="return checkForm(this)"로 부른다. 틀린 칸이 있으면 false로 제출을 막는다.
  window.checkForm = function (form) {
    var bad = 0, first = null;
    form.querySelectorAll("[data-v]").forEach(function (input) {
      if (input.disabled || input.closest("[hidden]")) return;
      var ok = check(input);
      show(input, ok);
      if (!ok) { bad++; if (!first) first = input; }
    });
    var summary = form.querySelector("[data-summary]");
    if (summary) {
      summary.hidden = bad < 2;                     // 둘 이상일 때만 맨 위 요약(한 칸이면 칸 이유로 충분)
      var p = summary.querySelector("p");
      if (p) p.textContent = summary.dataset.template.replace("{0}", bad);
    }
    if (bad) { first.focus(); return false; }
    return true;
  };

  // 칸을 떠날 때, 고칠 때 바로 검사
  document.querySelectorAll("form[data-validate]").forEach(function (form) {
    form.querySelectorAll("[data-v]").forEach(function (input) {
      var touched = false;
      input.addEventListener("blur", function () { touched = true; show(input, check(input)); });
      input.addEventListener("input", function () { input.dataset.changed = "1"; if (touched || input.closest(".invalid")) show(input, check(input)); });
    });
  });

  // 글자 수 표시
  document.querySelectorAll("[data-counter]").forEach(function (ta) {
    var out = document.querySelector(ta.dataset.counter);
    var max = +ta.dataset.max;
    function update() {
      var n = len(ta.value.trim());
      if (out) {
        out.textContent = n.toLocaleString() + "/" + max.toLocaleString();
        out.classList.toggle("over", n > max);
      }
    }
    ta.addEventListener("input", update);
    update();
  });
})();
