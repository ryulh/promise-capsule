/* 확인 알림창: [data-dialog="id"] 버튼이 <dialog id>를 열고, [data-close], Esc, 바깥 누름은 닫는다.
 * 확인 버튼은 알림창 안 POST 폼의 submit이라 이 파일은 제출에 관여하지 않는다. */
(function () {
  document.addEventListener("click", function (e) {
    var open = e.target.closest("[data-dialog]");
    if (open) {
      var d = document.getElementById(open.dataset.dialog);
      if (d && d.showModal) { d.showModal(); var f = d.querySelector("[data-close]"); if (f) f.focus(); }
      return;
    }
    var close = e.target.closest("[data-close]");
    if (close) { close.closest("dialog").close(); return; }
    if (e.target.tagName === "DIALOG") e.target.close(); /* 바깥(배경) 누름 */
  });
})();
