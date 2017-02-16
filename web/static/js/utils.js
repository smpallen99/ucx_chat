
export function remove(arr, item) {
  console.log('remove', arr, item)
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
