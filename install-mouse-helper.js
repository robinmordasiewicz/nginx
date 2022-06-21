// This injects a box into the page that moves with the mouse;
// Useful for debugging
async function installMouseHelper(page) {
  await page.evaluateOnNewDocument(() => {
    // Install mouse helper only for top-level frame.
    if (window !== window.parent)
      return;
    window.addEventListener('DOMContentLoaded', () => {
      const box = document.createElement('puppeteer-mouse-pointer');
      const styleElement = document.createElement('style');
      styleElement.innerHTML = `
        div.clickEffect{
          position:fixed;
          box-sizing:border-box;
          border-style:solid;
          border-color:#000000;
          border-radius:50%;
          animation:clickEffect 0.4s ease-out;
          z-index:99999;
        }
        @keyframes clickEffect{
          0%{
            opacity:1;
            width:0.5em; height:0.5em;
            margin:-0.25em;
            border-width:0.5rem;
          }
          100%{
            opacity:0.2;
            width:15em; height:15em;
            margin:-7.5em;
            border-width:0.03rem;
          }
        }
        puppeteer-mouse-pointer {
          pointer-events: none;
          position: absolute;
          top: 0;
          z-index: 10000;
          left: 0;
          width: 20px;
          height: 20px;
          background: rgba(0,255,0,0.2);
          border: 1px solid black;
          border-radius: 10px;
          margin: -10px 0 0 -10px;
          padding: 0;
          transition: background .2s, border-radius .2s, border-color .2s;
        }
        puppeteer-mouse-pointer.button-1 {
          transition: none;
          background: rgba(255,0,0,0.2);
        }
        puppeteer-mouse-pointer.button-2 {
          transition: none;
          border-color: rgba(0,0,255,0.2);
        }
        puppeteer-mouse-pointer.button-3 {
          transition: none;
          border-radius: 4px;
        }
        puppeteer-mouse-pointer.button-4 {
          transition: none;
          border-color: rgba(255,0,0,0.2);
        }
        puppeteer-mouse-pointer.button-5 {
          transition: none;
          border-color: rgba(0,255,0,0.2);
        }
      `;
      function clickEffect(e){
          var d=document.createElement("div");
          d.className="clickEffect";
          d.style.top=e.clientY+"px";d.style.left=e.clientX+"px";
          document.body.appendChild(d);
          d.addEventListener('animationend',function(){d.parentElement.removeChild(d);}.bind(this));
      }
      document.addEventListener('click',clickEffect);
      document.head.appendChild(styleElement);
      document.body.appendChild(box);
      document.addEventListener('mousemove', event => {
        box.style.left = event.pageX + 'px';
        box.style.top = event.pageY + 'px';
        updateButtons(event.buttons);
      }, true);
      document.addEventListener('mousedown', event => {
        updateButtons(event.buttons);
        box.classList.add('button-' + event.which);
      }, true);
      document.addEventListener('mouseup', event => {
        updateButtons(event.buttons);
        box.classList.remove('button-' + event.which);
      }, true);
      function updateButtons(buttons) {
        for (let i = 0; i < 5; i++)
          box.classList.toggle('button-' + i, buttons & (1 << i));
      }
    }, false);
  });
};

module.exports = {installMouseHelper};

