import * as utils from './utils'

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
      e.preventDefault()
      if (this.open) {
        this.close_picker()
      }
      else {
        this.open_picker()
      }
      return false
    })
    .on('click', '.filter-item', e => {
      e.preventDefault()
      let name = $(e.currentTarget).data('name')
      $('.filter-item').removeClass('active')
      $(e.currentTarget).addClass('active')
      $('.emoji-list').removeClass('visible')
      $(`.emoji-list.${name}`).addClass('visible')
      userchan.push('emoji:filter-item', {name: name})
      return false
    })
    .on('click', '.emojis li', e => {
      e.preventDefault()
      let emoji = $(e.currentTarget).find('img.emojione').attr('title')
      let pos = $('.input-message').getCursorPosition()
      $('.input-message').val((i, text) => {
        return text.slice(0,pos) + emoji + text.slice(pos)
      })
      this.close_picker()
      $('.input-message').focus()
      return false
    })
    .on('click', '.change-tone', e => {
      e.preventDefault()
      $('ul.tone-selector').toggleClass('show')
      return false
    })
    .on('click', 'a.tone', e => {
      e.preventDefault()
      let tone = $(e.currentTarget).data('tone')
      userchan.push("emoji:tone_list", {tone: tone})
        .receive("ok", resp => {
          resp.tone_list.forEach((name, i) => {
            let html = ""
            if (tone == "0") {
              html = utils.do_emojis(`:${name}:`)
            } else {
              html = utils.do_emojis(`:${name}_tone${tone}:`)
            }
            $(`li.emoji-${name}`).html(html)
          })
          $('ul.tone-selector').removeClass('show')
          $('span.current-tone').attr('class', 'current-tone tone-' + tone)
        })
      return false
    })
    .on('click', e => {
      if ($('.emoji-picker').hasClass('show')) {
        $('.emoji-picker').removeClass('show')
        e.preventDefault()
        return false
      }
    })
  }
  open_picker() {
    $('.emoji-picker').toggleClass('show')
  }
  close_picker() {
    $('.emoji-picker').toggleClass('show')
  }
  init_picker() {
    emojione.ascii = true

    $('.emoji-picker').css('bottom', '80px').css('left', '300px')
    let html = emojione.shortnameToImage($('.emojis').html())
    $('.emojis').html(html)
  }
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
