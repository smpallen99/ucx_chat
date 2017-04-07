import * as utils from './utils'
import * as flex from './flex_bar'
import toastr from 'toastr'
import * as sweet from './sweet'

window.toastr = toastr
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
        // console.log('admin flex receive', resp)
      })

  }
  click_tab_button(elem) {
    let type = elem.attr('class').replace(' row-link', '')
    let name = elem.data('name')
    let title = elem.attr('title')
    // console.log('clicked tab-button', type, name, this.current)

    if (this.current === undefined && title == 'User Info') {
      flex.toggle_tab_container()
      if ($('.flex-tab-container.opened').length == 0)
        $('.tab-button.active').removeClass('active')

    } else if (title == 'Invite Users') {
      if ($('.invite-users').closest('.flex-tab-container.opened').length == 0) {
        flex.toggle_tab_container()
        userchan.push('admin:flex:Invite Users')
          .receive("ok", resp => {
            // console.log('flex action resp', resp)
            $('section.flex-tab').html(resp.html).parent().addClass('opened')
            flex.set_tab_buttons_inactive()
            flex.set_tab_button_active(resp.title)
          })
          .receive("error", resp => {
            if (resp.error) { toastr.error(resp.error) }
          })
      } else {
        flex.toggle_tab_container()
        $('.tab-button.active[title="Invite Users"').removeClass('active')
      }
    } else {
      flex.toggle_tab_container()
      if ($('.flex-tab-container.opened').length == 0)
        $('.tab-button.active').removeClass('active')
    }
  }

  click_nav_button(elem) {
    let temp = elem.attr('class').split(' ')
    let action = temp[temp.length - 1]
    let username = elem.parent().data('username')
    // console.log('nav_button', action, username)
    switch(action) {
      case 'edit-user':
        userchan.push('admin:flex:action:' + action, {username: username})
          .receive("ok", resp => {
            // console.log('flex action resp', resp)
            $('section.flex-tab').html(resp.html).parent().addClass('opened')
            flex.set_tab_buttons_inactive()
            flex.set_tab_button_active(resp.title)
          })
          .receive("error", resp => {
            if (resp.error) { toastr.error(resp.error) }
          })

        break
      case 'make-admin':
      case 'remove-admin':
      case 'deactivate':
      case 'activate':
        userchan.push('admin:flex:action:' + action, {username: username})
          .receive("ok", resp => {
            // console.log('flex action resp', resp)
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
          gettext.deleting_user_delete_messages,
          gettext.yes_delete_it,
          function() {
            userchan.push('admin:flex:action:' + action, {username: username})
              .receive("ok", resp => {
                // if (resp.success) { toastr.success(resp.success) }
                sweet.warning_confirmation(gettext.deleted, gettext.the_user_has_been_deleted, 2000)
                flex.toggle_tab_container()
                $(`tr.row-link[data-name="${username}"]`).remove()
              })
              .receive("error", resp => {
                if (resp.error) { toastr.error(resp.error) }
                sweet.warning_confirmation(gettext.not_deleted, gettext.the_user_was_not_deleted, 2000)
              })
        })
        break
    }
  }

  register_event_handers(_this) {
    $('body')
      .on('click', 'section.page-list .row-link', function(e) {
        e.preventDefault()
        _this.click_row_link($(this))
        return false
      })
      .on('click', '.flex-tab-bar.admin .tab-button', function(e) {
        // console.log('clicked', $(this).attr('title'))
        e.preventDefault()
        _this.click_tab_button($(this))
        return false
      })
      .on('click', '.flex-tab.admin nav .button', function(e) {
        e.preventDefault()
        _this.click_nav_button($(this))
        return false
      })
      .on('click', '.invite-users nav button.send', function(e) {
        let email = $('#inviteEmails')
        let emails = email.val().replace('\n', ' ')
        userchan.push('admin:flex:send-invitation-email', {emails: emails})
          .receive("ok", resp => {
            // console.log('flex action resp', resp)
            $('section.flex-tab').html(resp.html).parent().addClass('opened')
            flex.set_tab_buttons_inactive()
            flex.set_tab_button_active(resp.title)
            if (resp.success)
              toastr.success(resp.success)
            if (resp.warning)
              toastr.warning(resp.warning)
          })
          .receive("error", resp => {
            if (resp.error) { toastr.error(resp.error) }
          })
      })
      .on('click', '.invite-users nav button.cancel', function(e) {
        flex.toggle_tab_container()
      })
      .on('click', '.invite-users .outstanding button.resend', function(e) {
        let email = $(e.currentTarget).data('email')
        let id = $(e.currentTarget).data('id')
        userchan.push('invitation:resend', {email: email, id: id})
          .receive("ok", resp => {
            if (resp.success) { toastr.success(resp.success) }
            $(`button[data-email="${email}"]`).next().append('<i class="icon-verified"></i>')
          })
          .receive("error", resp => {
            if (resp.error) { toastr.error(resp.error) }
          })
      })
  }
}


export default AdminFlexBar
