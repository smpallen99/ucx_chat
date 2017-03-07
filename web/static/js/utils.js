
const debug = false;

export function remove(arr, item) {
  if (debug) { console.log('remove', arr, item) }

  for(var i = arr.length; i--;) {
      if(arr[i] === item) {
          arr.splice(i, 1);
      }
  }
}
// Taken from: https://davidwalsh.name/javascript-debounce-function
//
// Returns a function, that, as long as it continues to be invoked, will not
// be triggered. The function will be called after it stops being called for
// N milliseconds. If `immediate` is passed, trigger the function on the
// leading edge, instead of the trailing.
//
// Usage:
//   var myEfficientFn = debounce(function() {
//     // All the taxing stuff you do
//   }, 250);
//
//   window.addEventListener('resize', myEfficientFn);
export function debounce(func, wait, immediate) {
  var timeout;
  return function() {
    var context = this, args = arguments;
    var later = function() {
      timeout = null;
      if (!immediate) func.apply(context, args);
    };
    var callNow = immediate && !timeout;
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
    if (callNow) func.apply(context, args);
  };
};

export function scroll_bottom() {
  let mypanel = $('.messages-box .wrapper')
  myPanel.scrollTop(myPanel[0].scrollHeight - myPanel.height());
}

export function empty_string(string) {
  return /^\s*$/.test(string)
}

export function loading_animation() {
  return `
    <div class='loading-animation'>
      <div class='bounce1'></div>
      <div class='bounce2'></div>
      <div class='bounce3'></div>
    </div`
}

export function page_loading() {

  let stylesheet = `<style>
    .loading-animation {
      top: 0;
      right: 0;
      bottom: 0;
      left: 0;
      display: flex;
      align-items: center;
      position: absolute;
      justify-content: center;
      text-align: center;
    }
    .loading-animation > div {
      width: 10px;
      height: 10px;
      margin: 2px;
      border-radius: 100%;
      display: inline-block;
      background-color: rgba(255,255,255,0.6);
      -webkit-animation: loading-bouncedelay 1.4s infinite ease-in-out both;
      animation: loading-bouncedelay 1.4s infinite ease-in-out both;
    }
    .loading-animation .bounce1 {
      -webkit-animation-delay: -0.32s;
      animation-delay: -0.32s;
    }
    .loading-animation .bounce2 {
      -webkit-animation-delay: -0.16s;
      animation-delay: -0.16s;
    }
    @-webkit-keyframes loading-bouncedelay {
      0%,
      80%,
      100% { -webkit-transform: scale(0) }
      40% { -webkit-transform: scale(1.0) }
    }
    @keyframes loading-bouncedelay {
      0%,
      80%,
      100% { transform: scale(0); }
      40% { transform: scale(1.0); }
    }
    </style>`
 $('head').prepend(stylesheet)
}

export function remove_page_loading() {
  $('head > style').remove()
}

export function code_update(resp) {
  console.log('code:update', resp)
  // let event = jQuery.Event( resp.selector + '-change' );

  if (resp.html) {
    $(resp.selector)[resp.action](resp.html)
  } else {
    $(resp.selector)[resp.action]()
  }
  // $('body').trigger(event)
}

window.pl = page_loading
window.rpl = remove_page_loading
