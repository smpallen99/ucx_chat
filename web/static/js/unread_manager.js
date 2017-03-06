import * as cc from './chat_channel'

const debug = false;

const new_message_unread_time = 5000;

// Handle the first-unread banner and the unread-bar with the following algorithm
// When the user's browser is not in focus (blur) and a new message comes in
// start a short timer and after that time, add 'unread-bar' to the DOM. This is
// a class on the unread message. If the browser comes back in focus before the
// timer expires, cancel the timer.
class UnreadManager {
  constructor() {
    this.view_elem = $('.messages-box .wrapper')[0];
    if (this.view_elem) {
      this.rect = this.view_elem.getBoundingClientRect()
      this.focus = document.hasFocus();
      this.unread = ucxchat.unread;
      this.unread_list = [];
      this.new_message_ref = undefined;
      this.is_loading = false
    }
  }

  get bounding() { return this.rect; }

  get has_focus() { return this.focus; }
  set has_focus(val) {
    if (val && this.new_message_ref) {
      clearTimeout(this.new_message_ref);
    }
    this.focus = val;
  }

  get is_unread() { return this.unread; }
  set is_unread(val) { this.unread = val; }

  count_unread() {
    var count = 0
    var p = this;
    this.unread_list.every(function(id) {
      if (p.is_visible($('#' + id))) {
        return false;
      } else {
        count++;
        return true;
      }
    })
    return count;
  }

  has_first_unread() {
    return $('.first-unread').length > 0;
  }

  hide_unread_bar() {
    let bar = $('.unread-bar')
    if (bar.length > 0) {
      bar.hide()
      this.unread = false
      this.unread_list = []
    }
  }

  is_first_unread_visible() {
    return this.is_visible($('.first-unread'))
  }

  is_unread_bar_visible() {
    return $('.unread-bar').is(':visible')
  }

  is_visible(jelem) {
    if (jelem.length > 0) {
      let elem = jelem[0]
      let eb = elem.getBoundingClientRect()
      if (eb.top > this.rect.top && eb.bottom < this.rect.bottom) {
        return true
      } else if (eb.top <= this.rect.top && eb.bottom >= this.rect.bottom) {
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }

  new_message(id) {
    if (!this.unread && !this.focus && !this.new_message_ref && !this.has_first_unread()) {
      this.new_message_ref = setTimeout(this.new_message_timeout, new_message_unread_time, this, id)
    }
    if (this.unread || this.new_message_ref) {
      if (debug) { console.log('new_message pushing id') }
      this.unread_list.push(id)
    } else {
      if (debug) { console.log('new_message not pushing id') }
    }
  }

  new_message_timeout(caller, id) {
    if (caller.new_message_ref) {
      $('#' + id)
        .addClass('first-unread')
        .addClass('first-unread-opaque');

      caller.is_unread = true;
      caller.new_message_ref = undefined;
      caller.push_channel('unread:set', {message_id: id})
    }
  }

  push_channel(message, args={}) {
    setTimeout(function() {
      cc.push(message, args)
    }, 20)
  }

  remove_unread() {
    if (debug) { console.log('remove_unread') }
    if (this.is_first_unread_visible() || !this.unread) {
      if (debug) { console.log('remove_unread removeing...') }
      this.remove_unread_class();
      this.unread = false;
    }
  }

  remove_unread_class() {
    if (this.has_first_unread()) {
      $('.first-unread').removeClass('first-unread first-unread-opaque')
      this.push_channel('unread:clear')
    }
  }

  scroll(e) {
    if (!this.isloading) {
      // if ($('.messages-box .wrapper').scrollTop().valueOf() == 0) {
      //   if (debug) { console.log('at the top...') }
      //   cc.push('messages:load', {timestamp: $('li.message').first().attr('data-timestamp')})
      //     .receive("ok", resp => {
      //       if (debug) { console.log('got response back from loading', resp) }
      //       $('.messages-box .wrapper ul').prepend(resp.html)
      //       if (debug) { console.log('finished loading') }
      //       this.isloading = false
      //     })
      //   return
      // }
    }
    if (this.unread) {
       if (debug) { console.log('scrolling unread') }
      if (this.is_first_unread_visible()) {
        if (debug) { console.log('hiding unread_bar') }

        if ($('.unread-bar').is(':visible')) {
          this.hide_unread_bar()
        }
      } else {
        let count = this.count_unread()
        if (!$('.unread-bar').is(':visible')) {
          $('.unread-bar').show()
          if (debug) { console.log('show unread bar') }
        } else {
          if (debug) { console.log('else dont show unread bar') }
        }
        $('.unread-cnt').html(count)
        if (debug) { console.log('count', count) }
      }
    } else {
       // if (debug) { console.log('scrolling no unread') }
    }
  }

}

var unread = new UnreadManager()
window.unread = unread;

$(document).ready(function() {
  $(window).on('focus', () => {
    unread.has_focus = true;
    systemchan.push('state:focus')
    if (debug) { console.log('focus') }
  }).on('blur', () => {
    unread.has_focus = false;
    systemchan.push('state:blur')
    if (debug) { console.log('blur') }
  })

  $('.messages-box .wrapper').scroll(function(e) {
    // if (debug) { console.log('scrolling....') }
    unread.scroll(e)
  })

  $('body').on('click', 'button.jump-to', function() {
    if (debug) { console.log('jumpto', $('.first-unread').offset().top) }
    unread.hide_unread_bar();
    unread.unread = false
    let msgbox = $('.messages-box .wrapper')
    let valof = msgbox.scrollTop().valueOf()
    let first_top = $('.first-unread').offset().top
    let offtop = msgbox.offset().top
    let val = msgbox.scrollTop().valueOf() + $('.first-unread').offset().top - msgbox.offset().top
    if (debug) { console.log('going to scroll to', valof, first_top, offtop, val) }
    $('.messages-box .wrapper').animate({
      scrollTop: val
    }, 1500);
    // $('.first-unread').get(0).scrollIntoView();
  })

  $('body').on('click', 'button.mark-read', function() {
    unread.remove_unread_class();
    unread.hide_unread_bar();

    let mypanel = $('.messages-box .wrapper')
    let val = myPanel[0].scrollHeight - myPanel.height();
    $('.messages-box .wrapper').animate({
      scrollTop: val
    }, 1500);
  })
  // scroll 30481
  // height 289
  // scroll position 29304
  // scrollTop 30168
  // offset top 60
  // offset.top - 797
  // height - 20
  // scrollTop(30168 - 797 - 60)
})

export default UnreadManager

