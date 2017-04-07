
const debug = false;

UcxChat.randomString = (length, charList) => {
  let chars = charList
  if (!chars)
    chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$%#@!'
  var result = '';
  for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
  return result;
}

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
  let elem = $('.messages-box .wrapper')[0]
  if (elem)
    elem.scrollTop = elem.scrollHeight - elem.clientHeight
  else
    console.warn('invalid elem')
}

export function scroll_down(height) {
  let elem = $('.messages-box .wrapper')
  if (elem)
    elem.scrollTop(getScrollBottom() + height)
  else
    if (debug) { console.warn('invalid elem') }
}

export function getScrollBottom() {
  let elem = $('.messages-box .wrapper')[0]
  if (elem) {
    return elem.scrollHeight - $(elem).innerHeight
  } else {
    if (debug) { console.warn('invalid elem') }
    return 1000
  }
}

export function is_scroll_bottom() {
  let elem = $('.messages-box .wrapper')[0]
  if (elem) {
    return elem.scrollTop + $(elem).innerHeight() + 1 >= elem.scrollHeight
  } else {
    if (debug) { console.warn('invalid elem') }
    return true
  }

}

export function empty_string(string) {
  return /^\s*$/.test(string)
}

export function loadmore_with_animation() {
  let d = document.createElement('li')
  return $(d).addClass('load-more').html(loading_animation())
}

export function loadmore() {
  return `<li class="load-more"></li>`
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
    #initial-page-loading .loading-animation {
      background: linear-gradient(to top, #6c6c6c 0%, #aaaaaa 100%);
      z-index: 1000;
    }
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
      z-index: 100;
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
  if (resp.html) {
    $(resp.selector)[resp.action](resp.html)
  } else {
    $(resp.selector)[resp.action]()
  }
  $('.input-message').focus()
}

export function push_history() {
  history.pushState(history.state, ucxchat.display_name, '/' + ucxchat.room_route + '/' + ucxchat.display_name)
}

export function replace_history() {
  history.replaceState(history.state, ucxchat.display_name, '/' + ucxchat.room_route + '/' + ucxchat.display_name)
}

window.pl = page_loading
window.rpl = remove_page_loading
