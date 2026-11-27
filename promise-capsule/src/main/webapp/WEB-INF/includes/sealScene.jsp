<%-- 봉인 애니메이션 층(봉인한 개설자에게 한 번) --%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<div class="scene-layer" id="sceneLayer" data-scene="seal">
<svg class="defs" width="0" height="0" aria-hidden="true"><defs>
  <clipPath id="holeClip" clipPathUnits="objectBoundingBox" transform="scale(0.00082237 0.00076923)"><path d="M0 0 H1216 V770 H954 A67 27 0 0 1 820 770 H412.5 A67 27 0 0 1 278.5 770 H0 Z"/></clipPath>
  <filter id="grain" x="-10%" y="-10%" width="120%" height="120%"><feTurbulence type="fractalNoise" baseFrequency=".35" numOctaves="2" seed="7" result="n"/><feColorMatrix in="n" type="matrix" values="0 0 0 0 .45  0 0 0 0 .3  0 0 0 0 .12  0 0 0 .22 0" result="g"/><feComposite in="g" in2="SourceGraphic" operator="in" result="gi"/><feBlend in="gi" in2="SourceGraphic" mode="multiply"/></filter>
</defs></svg>
<div class="scene seal">
          <p class="sr-only" role="status">${sealCaption}</p>
          <div class="world">
            <div class="pieces">
              <div class="ground"></div>
              <img class="capimg" alt="" src="${ctx}/assets/img/img-g1-capsule-v4.webp">
              <div class="lk"><img class="body" alt="" src="${ctx}/assets/img/img-hw2-plate.webp"><svg class="mark" viewBox="0 0 1016 884" aria-hidden="true"><g transform="translate(508 488)"><g fill="none" stroke="#F3D08C" stroke-width="22" opacity=".55" transform="translate(5 6)"><ellipse rx="196" ry="190"/></g><g fill="none" stroke="#86561A" stroke-width="22" opacity=".9"><ellipse rx="196" ry="190"/></g><g transform="translate(5 6)" opacity=".55"><path d="M0 -112 A112 112 0 0 0 0 112 Z" fill="#F3D08C"/><circle r="112" fill="none" stroke="#F3D08C" stroke-width="18"/></g><g opacity=".9"><path d="M0 -112 A112 112 0 0 0 0 112 Z" fill="#86561A"/><circle r="112" fill="none" stroke="#86561A" stroke-width="18"/></g></g></svg><div class="clip"><div class="sh"><svg viewBox="-100 -700 1216 1300" aria-hidden="true"><g filter="url(#grain)" fill="none" stroke-linecap="round"><path d="M245.5 110 V-45 A270.75 270.75 0 0 1 787 -45 V110" stroke="#7A4E17" stroke-width="128"/><path d="M245.5 110 V-45 A270.75 270.75 0 0 1 787 -45 V110" stroke="#D29A42" stroke-width="109"/><path d="M272.5 106 V-45 A243.75 243.75 0 0 1 760 -45 V106" stroke="#A86F22" stroke-width="24" opacity=".55"/><path d="M215.5 100 V-45 A300.75 300.75 0 0 1 817 -45 V100" stroke="#F4D08A" stroke-width="19" opacity=".8"/></g></svg></div></div></div>
            </div>
            <img class="hp" alt="" src="${ctx}/assets/img/img-g2g-promise-c.webp">
            <div class="lglow g1"></div>
            <div class="lglow g2"></div>
          </div>
          <button class="skip" type="button" data-skip><fmt:message key="common.skip"/></button>
          <p class="caption" aria-hidden="true">${sealCaption}</p>
        </div>
</div>
