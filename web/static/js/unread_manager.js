// import * as cc from './chat_channel'
// import * as utils from './utils'

// const debug = true;

// const new_message_unread_time = 5000;
// const animation = `<div class="loading-animation"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>`
// const loadmore = `<li class="load-more"></li>`

// const start_conversation = `<li class="start color-info-font-color">${gettext.start_of_conversation}</li>`


// // Handle the first-unread banner and the unread-bar with the following algorithm
// // When the user's browser is not in focus (blur) and a new message comes in
// // start a short timer and after that time, add 'unread-bar' to the DOM. This is
// // a class on the unread message. If the browser comes back in focus before the
// // timer expires, cancel the timer.
// class UnreadManager {
//   constructor() {
//     // this.view_elem = $('.messages-box .wrapper')[0];
//     // if (this.view_elem) {
//     //   this.rect = this.view_elem.getBoundingClientRect()
//     //   this.focus = document.hasFocus();
//     //   this.unread = ucxchat.unread;
//     //   this.unread_list = [];
//     //   this.new_message_ref = undefined;
//     //   this.is_loading = false
//     //   this.has_more = false
//     // }
//   }

// //   get bounding() { return this.rect; }

// //   get has_focus() { return this.focus; }
// //   set has_focus(val) {
// //     if (val && this.new_message_ref) {
// //       clearTimeout(this.new_message_ref);
// //     }
// //     this.focus = val;
// //   }

// //   get is_unread() { return this.unread; }
// //   set is_unread(val) { this.unread = val; }

// //   count_unread() {
// //     var count = 0
// //     var p = this;
// //     this.unread_list.every(function(id) {
// //       if (p.is_visible($('#' + id))) {
// //         return false;
// //       } else {
// //         count++;
// //         return true;
// //       }
// //     })
// //     return count;
// //   }

// //   has_first_unread() {
// //     return $('.first-unread').length > 0;
// //   }

// //   hide_unread_bar() {
// //     let bar = $('.unread-bar')
// //     if (bar.length > 0) {
// //       bar.hide()
// //       this.unread = false
// //       this.unread_list = []
// //     }
// //   }

// //   is_first_unread_visible() {
// //     return this.is_visible($('.first-unread'))
// //   }

// //   is_unread_bar_visible() {
// //     return $('.unread-bar').is(':visible')
// //   }

// //   is_visible(jelem) {
// //     if (jelem.length > 0) {
// //       let elem = jelem[0]
// //       let eb = elem.getBoundingClientRect()
// //       if (eb.top > this.rect.top && eb.bottom < this.rect.bottom) {
// //         return true
// //       } else if (eb.top <= this.rect.top && eb.bottom >= this.rect.bottom) {
// //         return true
// //       } else {
// //         return false
// //       }
// //     } else {
// //       return false
// //     }
// //   }

// //   get bounding() { return this.rect; }

// //   get has_focus() { return this.focus; }
// //   set has_focus(val) {
// //     if (val && this.new_message_ref) {
// //       clearTimeout(this.new_message_ref);
// //     }
// //     this.focus = val;
// //   }

// //   get is_unread() { return this.unread; }
// //   set is_unread(val) { this.unread = val; }

// //   count_unread() {
// //     var count = 0
// //     var p = this;
// //     this.unread_list.every(function(id) {
// //       if (p.is_visible($('#' + id))) {
// //         return false;
// //       } else {
// //         count++;
// //         return true;
// //       }
// //     })
// //     return count;
// //   }

// //   has_first_unread() {
// //     return $('.first-unread').length > 0;
// //   }

// //   hide_unread_bar() {
// //     let bar = $('.unread-bar')
// //     if (bar.length > 0) {
// //       bar.hide()
// //       this.unread = false
// //       this.unread_list = []
// //     }
// //   }

// //   is_first_unread_visible() {
// //     return this.is_visible($('.first-unread'))
// //   }

// //   is_unread_bar_visible() {
// //     return $('.unread-bar').is(':visible')
// //   }

// //   is_visible(jelem) {
// //     if (jelem.length > 0) {
// //       let elem = jelem[0]
// //       let eb = elem.getBoundingClientRect()
// //       if (eb.top > this.rect.top && eb.bottom < this.rect.bottom) {
// //         return true
// //       } else if (eb.top <= this.rect.top && eb.bottom >= this.rect.bottom) {
// //         return true
// //       } else {
// //         return false
// //       }
// //     } else {
// //       return false
// //     }
// //   }

// //   new_message(id) {
// //     if (!this.unread && !this.focus && !this.new_message_ref && !this.has_first_unread()) {
// //       this.new_message_ref = setTimeout(this.new_message_timeout, new_message_unread_time, this, id)
// //     }
// //     if (this.unread || this.new_message_ref) {
// //       if (debug) { console.log('new_message pushing id') }
// //       this.unread_list.push(id)
// //     } else {
// //       if (debug) { console.log('new_message not pushing id') }
// //     }
// //   }

// //   new_message_timeout(caller, id) {
// //     if (caller.new_message_ref) {
// //       $('#' + id)
// //         .addClass('first-unread')
// //         .addClass('first-unread-opaque');

// //       caller.is_unread = true;
// //       caller.new_message_ref = undefined;
// //       caller.push_channel('unread:set', {message_id: id})
// //     }
// //   }

// //   push_channel(message, args={}) {
// //     setTimeout(function() {
// //       cc.push(message, args)
// //     }, 20)
// //   }

// //   remove_unread() {
// //     if (debug) { console.log('remove_unread') }
// //     if (this.is_first_unread_visible() || !this.unread) {
// //       if (debug) { console.log('remove_unread removeing...') }
// //       this.remove_unread_class();
// //       this.unread = false;
// //     }
// //   }

// //   remove_unread_class() {
// //     if (this.has_first_unread()) {
// //       $('.first-unread').removeClass('first-unread first-unread-opaque')
// //       this.push_channel('unread:clear')
// //     }
// //   }

// //   new_room() {
// //     this.has_more = $('.messages-box li.load-more').length > 0
// //     bind_scroller()
// //     this.updateMentionsMarksOfRoom()
// //   }

// //   new_message(id) {
// //     if (!this.unread && !this.focus && !this.new_message_ref && !this.has_first_unread()) {
// //       this.new_message_ref = setTimeout(this.new_message_timeout, new_message_unread_time, this, id)
// //     }
// //     if (this.unread || this.new_message_ref) {
// //       if (debug) { console.log('new_message pushing id') }
// //       this.unread_list.push(id)
// //     } else {
// //       if (debug) { console.log('new_message not pushing id') }
// //     }
// //   }

// //   new_message_timeout(caller, id) {
// //     if (caller.new_message_ref) {
// //       $('#' + id)
// //         .addClass('first-unread')
// //         .addClass('first-unread-opaque');

// //       caller.is_unread = true;
// //       caller.new_message_ref = undefined;
// //       caller.push_channel('unread:set', {message_id: id})
// //     }
// //   }

// //   push_channel(message, args={}) {
// //     setTimeout(function() {
// //       cc.push(message, args)
// //     }, 20)
// //   }

// //   remove_unread() {
// //     if (debug) { console.log('remove_unread') }
// //     if (this.is_first_unread_visible() || !this.unread) {
// //       if (debug) { console.log('remove_unread removeing...') }
// //       this.remove_unread_class();
// //       this.unread = false;
// //     }
// //   }

// //   remove_unread_class() {
// //     if (this.has_first_unread()) {
// //       $('.first-unread').removeClass('first-unread first-unread-opaque')
// //       this.push_channel('unread:clear')
// //     }
// //   }

// //   new_room() {
// //     this.has_more = $('.messages-box li.load-more').length > 0
// //     bind_scroller()
// //     this.updateMentionsMarksOfRoom()
// //   }

// //   scroll() {
// //     if (!this.isloading && this.has_more) {
// //       this.updateMentionsMarksOfRoom()
// //       if ($('.messages-box .wrapper').scrollTop().valueOf() == 0) {
// //         let html = $('.messages-box .wrapper ul').html()
// //         let pos_elem = $('.messages-box .wrapper ul li[id]').first().attr('id')

// //         utils.page_loading()

// //         $('.messages-box .wrapper ul li.load-more').html(animation)

// //         cc.get('/messages', {timestamp: $('li.message').first().attr('data-timestamp')})
// //           .receive("ok", resp => {
// //             if (debug) { console.log('got response back from loading', resp) }

// //             $('.messages-box .wrapper ul')[0].innerHTML = resp.html + html

// //             if (debug) { console.log('finished loading', pos_elem) }

// //             scroll_to($('#' + pos_elem), -80)
// //             utils.remove_page_loading()

// //             if (!resp.has_more) {
// //               $('.messages-box .wrapper ul').children().first().addClass('new-day')
// //               $('.messages-box .wrapper ul').prepend(start_conversation)
// //             } else {
// //               $('li.load-more').remove()
// //               $('.messages-box .wrapper ul').prepend(loadmore)
// //             }
// //             this.isloading = false
// //           })
// //         return
// //       } else if (utils.is_scroll_bottom()) {
// //         // console.log('reached the bottom')
// //         if (this.has_more_next) {
// //           let html = $('.messages-box .wrapper ul').html()
// //           let ts = $('.messages-box li[data-timestamp]').last().data('timestamp')
// //           let pos_elem = $('.messages-box li[data-timestamp]').last().attr('id')
// //           utils.page_loading()

// //           cc.get('/messages/previous', {timestamp: ts})
// //             .receive("ok", resp => {

// //               $('.messages-box .wrapper ul')[0].innerHTML = html + resp.html

// //               scroll_to($('#' + pos_elem), 400)
// //               $('li.load-more').remove()
// //               if (resp.has_more_next) {
// //                 $('.jump-recent').addClass('not')
// //                 $('.messages-box .wrapper ul').append(loadmore)
// //               } else {
// //                 $('.jump-recent').removeClass('not')
// //               }

// //               utils.remove_page_loading()
// //             })

// //         } else {
// //            $('.jump-recent').hasClass('not')
// //         }
// //         $('.jump-recent').addClass('not')
// //       }
// //     }
// //     if (this.unread) {
// //        if (debug) { console.log('scrolling unread') }
// //       if (this.is_first_unread_visible()) {
// //         if (debug) { console.log('hiding unread_bar') }

// //         if ($('.unread-bar').is(':visible')) {
// //           this.hide_unread_bar()
// //         }
// //       } else {
// //         let count = this.count_unread()
// //         if (!$('.unread-bar').is(':visible')) {
// //           $('.unread-bar').show()
// //           if (debug) { console.log('show unread bar') }
// //         } else {
// //           if (debug) { console.log('else dont show unread bar') }
// //         }
// //         $('.unread-cnt').html(count)
// //         if (debug) { console.log('count', count) }
// //       }
// //     } else {
// //        // if (debug) { console.log('scrolling no unread') }
// //     }
// //   }

// // }

// // var unread = new UnreadManager()
// // window.unread = unread;

// // // function bind_scroller() {
// // //   $('.messages-box .wrapper').bind('scroll', function(e) {
// // //     // if (debug) { console.log('scrolling....') }
// // //     unread.scroll()
// // //     // if (unread.throttle == undefined) {
// // //     //   console.log('call scroll')
// // //     //   this.throttle = setTimeout(() => {
// // //     //     this.throttle = undefined
// // //     //     unread.scroll()
// // //     //   }, 500)
// // //     //   unread.scroll()
// // //     // }
// // //   })
// // // }


// // // $(document).ready(function() {
// // //   bind_scroller()
// // //   // $('.messages-box .wrapper').scroll(function(e) {
// // //   //   // if (debug) { console.log('scrolling....') }
// // //   //   unread.scroll(e)
// // //   // })

// // //   // scroll 30481
// // //   // height 289
// // //   // scroll position 29304
// // //   // scrollTop 30168
// // //   // offset top 60
// // //   // offset.top - 797
// // //   // height - 20
// // //   // scrollTop(30168 - 797 - 60)
// // // })

// export default UnreadManager

