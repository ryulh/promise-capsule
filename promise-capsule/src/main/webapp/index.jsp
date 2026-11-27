<%-- 소개. 로그인 상태면 내 캡슐로. --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:if test="${not empty sessionScope.userId}"><jsp:forward page="/capsule/capsules.jsp"/></c:if>
<c:set var="titleKey" value="intro.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
  <main class="page">
    <div class="wrap">
      <%@ include file="/WEB-INF/includes/notice.jsp" %>

      <section class="hero">
        <%-- 진행 과정 슬라이드 4장 --%>
        <div class="slides" aria-roledescription="carousel" aria-label="<fmt:message key='intro.slides'/>">
          <div class="slide-track" id="track" tabindex="0">
            <c:forEach var="i" begin="1" end="4">
              <figure class="slide"><img class="art r4x3" alt="" src="${ctx}/assets/img/img-01${i == 1 ? 'a' : i == 2 ? 'b' : i == 3 ? 'c' : 'd'}.webp" width="1536" height="1024">
                <figcaption><b>${i}/4</b> <span><fmt:message key="intro.slide${i}"/></span></figcaption></figure>
            </c:forEach>
          </div>
          <div class="slide-nav">
            <button type="button" class="slide-btn" data-dir="-1" aria-label="<fmt:message key='intro.prev'/>"><svg class="ic" aria-hidden="true"><use href="${icons}#i-chevron-left"/></svg></button>
            <span class="dots" aria-hidden="true"><i></i><i></i><i></i><i></i></span>
            <button type="button" class="slide-btn" data-dir="1" aria-label="<fmt:message key='intro.next'/>"><svg class="ic" aria-hidden="true"><use href="${icons}#i-chevron-right"/></svg></button>
            <%-- 정지, 재생 --%>
            <button type="button" class="slide-btn" id="slideToggle" data-label-pause="<fmt:message key='intro.pause'/>" data-label-play="<fmt:message key='intro.play'/>" aria-label="<fmt:message key='intro.pause'/>"><svg class="ic" aria-hidden="true"><use href="${icons}#i-pause"/></svg></button>
          </div>
        </div>
        <div class="stack hero-text">
          <h1><fmt:message key="intro.h1"/></h1>
          <p class="lead"><fmt:message key="intro.lead"/></p>
          <div class="cta">
            <a class="btn primary" href="${ctx}/account/signup.jsp"><fmt:message key="intro.start"/></a>
            <a class="btn ghost" href="${ctx}/account/login.jsp"><fmt:message key="intro.haveAccount"/></a>
          </div>
          <p class="small muted flush"><fmt:message key="intro.inviteHint"/></p>
        </div>
      </section>

      <%-- 이렇게 써요: 핵심 여정 4단계 --%>
      <section class="sec">
        <div class="section-head"><h2><fmt:message key="intro.how"/></h2></div>
        <ol class="steps">
          <c:forTokens var="icon" items="pencil,mail,lock,lock-open" delims="," varStatus="s">
            <li><span class="num">0${s.count}</span><span class="ico"><svg class="ic" aria-hidden="true"><use href="${icons}#i-${icon}"/></svg></span><h3><fmt:message key="intro.step${s.count}.title"/></h3><p><fmt:message key="intro.step${s.count}.body"/></p></li>
          </c:forTokens>
        </ol>
      </section>

      <%-- 약속: 차별점 3가지 --%>
      <section class="sec">
        <div class="section-head"><h2><fmt:message key="intro.promise"/></h2></div>
        <div class="promises">
          <c:forEach var="i" begin="1" end="3">
            <div class="box"><h3><fmt:message key="intro.promise${i}.title"/></h3><p><fmt:message key="intro.promise${i}.body"/></p></div>
          </c:forEach>
        </div>
      </section>

      <%-- 마지막 행동 유도 --%>
      <section class="sec">
        <div class="cta-band">
          <h2 class="flush"><fmt:message key="intro.cta.title"/></h2>
          <p class="muted flush"><fmt:message key="intro.cta.body"/></p>
          <a class="btn primary" href="${ctx}/account/signup.jsp"><fmt:message key="intro.cta.button"/></a>
        </div>
      </section>
    </div>
  </main>
<script>
  /* 슬라이드: 5초 자동. 마우스를 올리면 잠깐 멈추고, 초점, 터치, 누름은 재생을 누를 때까지 멈춘다(정지, 재생 버튼 자신은 제외).
     동작 줄이기면 자동 넘김 없음. 타이머는 항상 하나. */
  (function () {
    var track = document.getElementById("track"), box = document.querySelector(".slides");
    var toggle = document.getElementById("slideToggle"), dots = document.querySelectorAll(".dots i"), n = dots.length;
    var reduce = window.matchMedia && matchMedia("(prefers-reduced-motion: reduce)").matches;
    var playing = !reduce, hover = false, timer = null;
    function idx() { return Math.round(track.scrollLeft / track.clientWidth); }
    function go(i) { i = (i + n) % n; track.scrollTo({ left: i * track.clientWidth, behavior: reduce ? "auto" : "smooth" }); }
    function mark() { var k = idx(); dots.forEach(function (d, j) { d.classList.toggle("on", j === k); }); }
    function tick() { clearInterval(timer); timer = null; if (playing && !hover) timer = setInterval(function () { go(idx() + 1); }, 5000); }
    function setPlaying(p) {
      playing = p;
      toggle.setAttribute("aria-label", p ? toggle.dataset.labelPause : toggle.dataset.labelPlay);
      toggle.querySelector("use").setAttribute("href", toggle.querySelector("use").getAttribute("href").replace(/#i-(pause|play)$/, p ? "#i-pause" : "#i-play"));
      tick();
    }
    function stopByUser(e) { if (!toggle.contains(e.target)) setPlaying(false); }
    document.querySelectorAll(".slide-btn[data-dir]").forEach(function (b) {
      b.addEventListener("click", function () { setPlaying(false); go(idx() + Number(b.dataset.dir)); });
    });
    toggle.addEventListener("click", function () { hover = false; setPlaying(!playing); });
    track.addEventListener("scroll", function () { requestAnimationFrame(mark); });
    box.addEventListener("focusin", stopByUser);
    box.addEventListener("touchstart", stopByUser, { passive: true });
    box.addEventListener("pointerdown", stopByUser);
    box.addEventListener("mouseenter", function () { hover = true; tick(); });
    box.addEventListener("mouseleave", function () { hover = false; tick(); });
    if (reduce) toggle.hidden = true;
    mark();
    setPlaying(playing);
  })();
</script>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
