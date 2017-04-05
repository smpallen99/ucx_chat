import * as utils from './utils'
import * as reaction from './reaction'

let debug = true

class ChatEmoji {
  constructor() {
    this.open = false
    this.cursor_position_plugin()
    this.register_events()
    this.init_picker()
    this.reactions = false
  }
  open_reactions(elem, message_id) {
    this.reactions = message_id
    let offset = $(elem).offset()

    setTimeout(() => {
      this.open_picker(offset)
    }, 50)
  }
  update_recent(emoji) {
    $('.input-message').focus()
    userchan.push('emoji:recent', {recent: emoji})
      .receive("ok", resp => {
        if (resp.html) {
          $('.emojis ul.recent').html(resp.html)
        }
      })
  }

  select_input(e, emoji) {
    let pos = $('.input-message').getCursorPosition()
    $('.input-message').val((i, text) => {
      return text.slice(0,pos) + emoji + text.slice(pos)
    })
    this.close_picker()
    this.update_recent(emoji)
  }
  select_reactions(e, emoji) {
    reaction.select(emoji, this.reactions)
    this.close_picker()
  }
  register_events() {
    $('body')
    .on('click', '.emoji-picker-icon', e => {
      e.preventDefault()
      this.reactions = false
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
      $('.emoji-filter input.search').val('')
      userchan.push('emoji:filter-item', {name: name})
      return false
    })
    .on('click', '.emojis li', e => {
      e.preventDefault()
      let emoji = $(e.currentTarget).find('span.emojione').attr('title')
      if (this.reactions) {
        this.select_reactions(e, emoji)

      } else {
        this.select_input(e, emoji)
      }
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
          let obj = resp.tone_list
          Object.keys(obj).forEach((key, index) => {
            $(`li.emoji-${key}`).html(obj[key])
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
    .on('click', '.emoji-filter input.search', e => {
      e.preventDefault()
      return false
    })
    .on('keyup', '.emoji-filter input.search', e => {
      let text = $('.emoji-filter input.search').val()
      let category = $('.filter-item.active').data('name')
      userchan.push('emoji:search', {pattern: text, category: category})
        .receive("ok", resp => {
          if (resp.html) {
            $('.emojis ul.' + category).html(resp.html)
          }
        })
    })
  }
  open_picker(offset) {
    $('.emoji-picker').addClass('show')
    if (offset) {
      let height = window.innerHeight
      let body_width = $('body').width()
      let picker = $('.emoji-picker')
      let picker_offset = picker.offset()
      let left = offset.left
      let bottom = height - offset.top + 10

      if ((left + picker.width()) > body_width) {
        left = body_width - picker.width() - 20
      }

      let top = height - (bottom + picker.height())
      if (top < 0) {
        bottom = bottom - picker.height() - 50
      }

      $('.emoji-picker').css('bottom', bottom + 'px').css('left', left + 'px')
    }
  }
  close_picker() {
    this.reactions = false
    $('.emoji-picker').removeClass('show')
  }
  init_picker() {
    // emojione.ascii = true

    $('.emoji-picker').css('bottom', '80px').css('left', '300px')
    // let html = emojione.shortnameToImage($('.emojis').html())
    // $('.emojis').html(html)
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
