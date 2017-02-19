import * as cc from './chat_channel'
import * as utils from './utils'

const debug = true;

const popup_window = '.message-popup-results';
const item = '.popup-item';
const selected = item + '.selected';
const form_text = 'textarea.message-form-text';

const application_matches = {users: /(^|\s)@([^\s]*)$/, slashcommands: /^\/[^\s]*$/}
const application_command_chars   = {users: "@", slashcommands: "/"}

class MessagePopup {

  constructor() {
    // this.open = undefined;
    this.application = undefined;
    this.match = undefined
    this.command_char = undefined;
    this.pattern = [];
  }

  close_popup() {
    $(popup_window).html('')
    this.set_focus()
    // this.open = undefined
    this.application = undefined
    this.match = undefined
    this.command_char = undefined;
    this.pattern = []
  }

  handle_enter() {
    if (this.application) {
      let selected = $('.popup-item.selected')
      if (selected.length == 1) {
        this.select_item(selected)
      }
      this.close_popup()
    }
  }

  handle_key(keyCode) {
    this.pattern.push(keyCode)
    cc.push('message_popup:get:' + this.application, {pattern: this.pattern})
      .receive("ok", resp => {
        if (resp.close) {
          this.close_popup()
        } else {
          this.handle_channel_resp(resp)
        }
    })
  }

  handle_up_arrow_key() {
    let prev = $(selected).prev()
    $(selected).removeClass('selected')

    if (prev.length > 0) {
      prev.addClass('selected')
    } else {
      $(item).last().addClass('selected')
    }
    return false
  }

  handle_down_arrow_key() {
    let next = $(selected).next()
    $(selected).removeClass('selected')

    if (next.length > 0) {
      next.addClass('selected')
    } else {
      $(item).first().addClass('selected')
    }
    return false
  }

  handle_bs_key() {
    if (debug) { console.log('BS') }
    if ($(form_text).val().slice(-1) != this.application_char) {
      if (this.pattern.length == 0) {
        this.close_popup()
        return true
      }
      this.pattern.pop()
      cc.push('message_popup:get:' + this.application, {pattern: this.pattern})
        .receive("ok", resp => {
          if (resp.close) {
            this.close_popup()
          } else {
            this.handle_channel_resp(resp)
          }
      })
    } else {
      this.close_popup()
    }
    return true
  }

  handle_bs_key_not_open() {
    let match = undefined

    if (match = $(form_text).val().match(application_matches.users)) {
      this.set_application("users")
    } else if (match = $(form_text).val().match(application_matches.slashcommands)) {
      this.set_application("slashcommands")
    }

    if (match) {
      let string = match[match.length - 1].slice(0, -1)
      let pattern = []
      console.log('...... inside match', match, string)
      for(var i = 1; i < string.length; i++) { pattern.push(string.charCodeAt(i)) }
      cc.push('message_popup:get:' + this.application, {pattern: pattern})
        .receive("ok", resp => {
          if (debug) { console.log('bs not open resp', pattern, resp) }
          if (!resp.close) {
            this.pattern = pattern
            this.handle_channel_resp(resp)
          } else {
            this.close_popup()
          }
        })
    }
    return true
  }

  handle_tab_key() {
    this.select_item($(selected))
    this.close_popup()
    return false
  }

  open_application(application, pattern=[]) {
    this.set_application(application)

    cc.push('message_popup:get:' + this.application, {pattern: pattern})
      .receive("ok", resp => {
        this.handle_channel_resp(resp)
    })
  }

  set_application(application) {
    this.application = application;
    this.match = application_matches[application]
    this.command_char = application_command_chars[application]
  }

  handle_channel_resp(resp) {
    $(popup_window).html(resp.html)
    $('.popup-item').hover(
      function() {
        $('.popup-item.selected').removeClass('selected')
        $(this).addClass('selected')
      },
      function() {
        // $(this).removeClass('selected') //.attr('style', 'color: rgb(160,160.160);')
      });
    $('.popup-item').click(function() {
      message_popup.select_item($(this))
      message_popup.close_popup()
    })
  }

  set_focus() {
    $(form_text).focus()
  }

  register_user_input() {
    $('body').on('user:input', msg => {
      console.log('register input', this.application)
      if (this.application) {
        switch(msg.keyCode) {
          case 38: // up arrow
            return this.handle_up_arrow_key()
          case 40: // down arrow
            return this.handle_down_arrow_key()
          case 8:  // BS
            return this.handle_bs_key()
          case 9:  // TAB
            return this.handle_tab_key()
          default:
            return this.handle_key(msg.keyCode)
        }
      } else {
        if (msg.keyCode == 64) {
          // if (debug) { console.log('found @', "'" + $(form_text).val() + "'") }
          let prev = $(form_text).val().slice(-1);
          if (prev == "" || prev == " ") {
            this.open_application("users")
          }
        } else if (msg.keyCode == 47 && $(form_text).val() == "") {
          console.log('opening slashcommands')
          this.open_application("slashcommands")

        } else if (msg.keyCode == 8) { // BS
          return this.handle_bs_key_not_open()
        }
      }
    })
  }

  select_item(elem) {
    let text = $('.message-form-text').val()
    let expression = "(.*)" + this.command_char + "(.*$)"
    let re = new RegExp(expression)
    console.log('select_item text', text)
    let new_text = text.replace(re, "$1" + this.command_char + elem.attr('data-name') + ' ')
    $('.message-form-text').val(new_text)
  }

}

window.message_popup = new MessagePopup();
message_popup.register_user_input();

export default MessagePopup
