import * as utils from './utils'
import * as flex from './flex_bar'
import toastr from 'toastr'
import * as sweet from './sweet'

const debug = false;

class AdminFlexBar {
  constructor() {
    this.current = undefined;
    this.register_event_handers(this)
  }

  click_row_link(elem) {
    let type = elem.attr('class').replace(' row-link', '')
    let name = elem.data('name')
    console.log('clicked link-row', type, name, this.current)

    userchan.push('admin:flex:' + type, {name: name})
      .receive("ok", resp => {
        $('section.flex-tab').html(resp.html).parent().addClass('opened')
        flex.set_tab_buttons_inactive()
        flex.set_tab_button_active(resp.title)
        console.log('admin flex receive', resp)
      })

  }
  click_tab_button(elem) {
    let type = elem.attr('class').replace(' row-link', '')
    let name = elem.data('name')
    console.log('clicked tab-button', type, name, this.current)

    if (this.current === undefined && elem.attr('title') == 'User Info') {
      flex.toggle_tab_container()
    }
  }

  click_nav_button(elem) {
    let temp = elem.attr('class').split(' ')
    let action = temp[temp.length - 1]
    let username = elem.parent().data('username')
    console.log('nav_button', action, username)
    switch(action) {
      case 'edit-user':
      case 'make-admin':
      case 'remove-admin':
      case 'deactivate':
      case 'activate':
        userchan.push('admin:flex:action:' + action, {username: username})
          .receive("ok", resp => {
            console.log('flex action resp', resp)
            if (resp.success) { toastr.success(resp.success) }
            if (resp.code_update) {
              utils.code_update(resp.code_update)
            }

          })
          .receive("error", resp => {
            if (resp.error) { toastr.error(resp.error) }
          })
        break
      case 'delete':
        sweet.warning(
          'Deleting a user will delete all messages from that user as well. This cannot be undone.',
          'Yes, delete it!',
          function() {
            userchan.push('admin:flex:action:' + action, {username: username})
              .receive("ok", resp => {
                if (resp.success) { toastr.success(resp.success) }
                sweet.warning_confirmation('Deleted', 'The user has been deleted', 2000)
              })
              .receive("error", resp => {
                if (resp.error) { toastr.error(resp.error) }
                sweet.warning_confirmation('Not Deleted', 'The user was not deleted', 2000)
              })
        })
        break
    }
  }

  register_event_handers(_this) {
    $('body').on('click', 'section.page-list .row-link', function(e) {
      e.preventDefault()
      _this.click_row_link($(this))
      return false
    })
    $('body').on('click', '.flex-tab-bar.admin .tab-button', function(e) {
      e.preventDefault()
      _this.click_tab_button($(this))
      return false
    })
    $('body').on('click', '.flex-tab.admin nav .button', function(e) {
      e.preventDefault()
      _this.click_nav_button($(this))
      return false
    })
  }
}


export default AdminFlexBar
