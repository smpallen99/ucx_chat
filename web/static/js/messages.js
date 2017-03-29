import * as cc from "./chat_channel"
import hljs from "highlight.js"
import * as utils from "./utils"
import * as main from "./main"

const debug = true;

import EmojiPicker from "rm-emoji-picker";

// window.Converters = require('Converters')

class Messages {
  constructor() {
    $('body').on('click', '.select-category', e => {
      setTimeout(() => {
        $('.emoji-section.emoji-content').scrollTop($('.emoji-section.emoji-content').scrollTop() + 3)
      },5)
    })
    this.picker = new EmojiPicker({
      sheets: {
        apple   : '/sheets/sheet_apple_64_indexed_128.png',
        google  : '/sheets/sheet_google_64_indexed_128.png',
        twitter : '/sheets/sheet_twitter_64_indexed_128.png',
        emojione: '/sheets/sheet_emojione_64_indexed_128.png'
      },
      show_colon_preview: false,
      callback   : (emoji, category, node) => {
        console.log('callback, node')
        // if(node instanceof HTMLELement){
        //     node.classList.add('emoji-image')
        // }
      },
      categories: [
        {
            title: "People",
            icon : '<i class="fa fa-smile-o" aria-hidden="true"></i>'
        },
        {
            title: "Nature",
            icon : '<i class="fa fa-leaf" aria-hidden="true"></i>'
        },
        {
            title: "Foods",
            icon : '<i class="fa fa-cutlery" aria-hidden="true"></i>'
        },
        {
            title: "Activity",
            icon : '<i class="fa fa-futbol-o" aria-hidden="true"></i>'
        },
        {
            title: "Places",
            icon : '<i class="fa fa-globe" aria-hidden="true"></i>'
        },
        {
            title: "Symbols",
            icon : '<i class="fa fa-lightbulb-o" aria-hidden="true"></i>'
        },
        {
            title: "Flags",
            icon : '<i class="fa fa-flag-checkered" aria-hidden="true"></i>'
        }
      ]
    });
    const icon      = $('i.emoji-picker-icon')[0]
    const container = $('.message-popup-results')[0];
    const editable  = $('.message-form-text')[0];

    this.picker.listenOn(icon, container, editable);

    setInterval(() => {
        console.log(this.picker.getText());
    }, 3000);
  }

  static new_message(msg) {
    let html = msg.html

    let at_bottom = roomManager.at_bottom
    console.log('new_message', msg)

    html = utils.do_emojis(html)

    $('.messages-box .wrapper > ul').append(html)

    $('.messages-box').children('.wrapper').children('ul').children(':last-child').find('pre').each(function(i, block) {
      hljs.highlightBlock(block)
    })

    if (ucxchat.user_id == msg.user_id) {
      if (debug) { console.log('adding own to', msg.id, $('#' + msg.id)) }
      $('#' + msg.id).addClass("own")
      main.run()
    }
    main.update_mentions(msg.id)

    if (at_bottom || msg.user_id == ucxchat.user_id) {
      utils.scroll_bottom()
    }

    roomManager.new_message(msg.id, msg.user_id)
  }
  static update_message(msg) {
    $('#' + msg.id).replaceWith(msg.html)
      .find('pre').each(function(i, block) {
        hljs.highlightBlock(block)
      })

    if (ucxchat.user_id == msg.user_id) {
      // if (debug) { console.log('adding own to', msg.id, $('#' + msg.id)) }
      $('#' + msg.id).addClass("own")
    }
    roomManager.new_message(msg.id)
  }
  static scroll_bottom() {
    let mypanel = $('.messages-box .wrapper')
    myPanel.scrollTop(myPanel[0].scrollHeight - myPanel.height());
  }

  static send_message(msg) {
    let user = window.ucxchat.user_id
    let ucxchat = window.ucxchat
    if (msg.update) {
      cc.put("/messages/" + msg.update, {message: msg.value, user_id: user})
        .receive("ok", resp => {
          $('.message-form-text').removeClass('editing')
          if (resp.html) {
            $('.messages-box .wrapper > ul').append(resp.html)
            $('.messages-box').children('.wrapper').children('ul').children(':last-child').find('pre').each(function(i, block) {
              hljs.highlightBlock(block)
            })
            utils.scroll_bottom()
            console.log('got response from send message')
          }
        })

    } else if (msg.startsWith('/')) {
      let match = msg.match(/^\/([^\s]+)(.*)/)
      let route = "/slashcommand/" + match[1]
      cc.put(route, {args: match[2].trim()})
        .receive("ok", resp => {
          // console.log('slash command resp', resp )
          if (resp.html) {
            $('.messages-box .wrapper > ul').append(resp.html)
            utils.scroll_bottom()
          }
        })

      roomManager.remove_unread()

    } else if (!utils.empty_string(msg)) {
      // roomchan.push("message", {message: msg, user_id: user, room: ucxchat.room, username: ucxchat.username,
      //   user_id: ucxchat.user_id, channel_id: ucxchat.channel_id})
      // cc.push("message", {message: msg, user_id: user})
      cc.post("/messages", {message: msg, user_id: user})
        .receive("ok", resp => {
          if (resp.html) {
            $('.messages-box .wrapper > ul').append(resp.html)
            $('.messages-box').children('.wrapper').children('ul').children(':last-child').find('pre').each(function(i, block) {
              hljs.highlightBlock(block)
            })
            Messages.scroll_bottom()
          }
        })

      roomManager.remove_unread()
    }

    $('.message-form-text').val('')
  }
}
export default Messages;
