let debug = true
class ChatEmoji {
  constructor() {
    this.open = false
    this.cursor_position_plugin()
    this.register_events()
    this.init_picker()
  }
  register_events() {
    $('body')
    .on('click', '.emoji-picker-icon', e => {
      console.log('emoji open click')
      if (this.open)
        this.close_picker()
      else
        this.open_picker()
    })
    .on('click', '.filter-item', e => {
      let name = $(e.currentTarget).data('name')
      $('.filter-item').removeClass('active')
      $(e.currentTarget).addClass('active')
      $('.emoji-list').removeClass('visible')
      $(`.emoji-list.${name}`).addClass('visible')
    })
    .on('click', '.emojis li', e => {
      let emoji = ':' + $(e.currentTarget).data('emoji') + ':'
      let pos = $('.input-message').getCursorPosition()
      console.log('pos', pos)
      $('.input-message').val((i, text) => {
        return text.slice(0,pos) + emoji + text.slice(pos)
      })
      this.close_picker()
      $('.input-message').focus()
    })
  }
  open_picker() {
    $('.emoji-picker').toggleClass('show')
    // userchan.push('emoji:open_picker')
    //   .receive("ok", resp => {

    //   })

  }
  close_picker() {
    $('.emoji-picker').toggleClass('show')
    // userchan.push('emoji:close_picker')
  }
  init_picker() {
    $('.emoji-picker').css('bottom', '80px').css('left', '300px')
    let html = emojione.shortnameToImage($('.emojis').html())
    $('.emojis').html(html)
  }
  // cursor_position_plugin() {
  //   (function ($, undefined) {
  //       $.fn.getCursorPosition = function() {
  //           var el = $(this).get(0);
  //           var pos = 0;
  //           if('selectionStart' in el) {
  //               pos = el.selectionStart;
  //           } else if('selection' in document) {
  //               el.focus();
  //               var Sel = document.selection.createRange();
  //               var SelLength = document.selection.createRange().text.length;
  //               Sel.moveStart('character', -el.value.length);
  //               pos = Sel.text.length - SelLength;
  //           }
  //           return pos;
  //       }
  //   })(jQuery);
  // }
  cursor_position_plugin() {
    $.fn.getCursorPosition = function() {
        var el = $(this).get(0);
        var pos = 0;
        if('selectionStart' in el) {
            pos = el.selectionStart;
        } else if('selection' in document) {
            el.focus();
            var Sel = document.selection.createRange();
            var SelLength = document.selection.createRange().text.length;
            Sel.moveStart('character', -el.value.length);
            pos = Sel.text.length - SelLength;
        }
        return pos;
    }
  }
}

$(document).ready(() => {
  window.chat_emoji = new ChatEmoji()
})

export default ChatEmoji
