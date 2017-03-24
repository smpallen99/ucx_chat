import toastr from 'toastr'

const reset_i = '<i class="icon-ccw secondary-font-color color-error-contrast"></i>'

class Admin {
  constructor() {
    this.modifed = false
    this.register_events(this)
  }

  enable_save_button() {
    let save = $('button.save')
    if (save.attr('disabled') == 'disabled') {
      save.removeAttr('disabled')
      save.parent().prepend(`<button class="button danger discard"><i class="icon-send"></i><span>${gettext.cancel}</span></button>`)
      this.modified = true
    }
  }
  disable_save_button() {
    let save = $('button.save')
    this.modified = false
    save.attr('disabled', 'disabled')
    $('button.discard').remove()
  }
  register_events(admin) {
    $('body')
      .on('click', 'button.discard', function() {
        // admin.disable_save_button()
        $('a.admin-link[data-link="info"]').click()
      })
      .on('change', '.admin-settings form input', function(e) {
        let target = e.currentTarget
        admin.enable_save_button()
        let reset = `<button text='Reset' data-setting="${target.getAttribute('name')}" class="reset-setting button danger">${reset_i}</button>`
        $(this).closest('.input-line').addClass('setting-changed') //.append(reset)
      })
      .on('keyup keypress paste', '.admin-settings form input', function(e) {
        admin.enable_save_button()
        $(this).closest('.input-line').addClass('setting-changed') //.append(reset)
      })
      .on('change', '.permissions-manager [type="checkbox"]', function(e, t) {
        e.preventDefault()
        console.log('checkbox change t', $(this))
        let name = $(this).attr('name')
        let value = $(this).is(':checked')

        if (!value) { value = "false" }
        userchan.push('admin:permissions:change:' + name, {value: value})
        .receive("ok", resp => {
          // stop_loading_animation()
          toastr.success('Room ' + name + ' updated successfully.')
        })
      })
      .on('click', '.page-settings .section button.expand', function(e) {
        e.preventDefault()
        $(this)
          .addClass('collapse')
          .removeClass('expand')
          .first().html('Collapse')
          .closest('.section-collapsed')
          .removeClass('section-collapsed')
      })
      .on('click', '.page-settings .section button.collapse', function(e) {
        e.preventDefault()
        $(this)
          .removeClass('collapse')
          .addClass('expand')
          .first().html('Expand')
          .closest('.section-title')
          .parent()
          .addClass('section-collapsed')
      })
      .on('click', '.admin-settings button.save', function(e) {
        console.log('saving form....', $('form').data('id'))
        e.preventDefault()
        userchan.push('admin:save:' + $('form').data('id'), $('form').serializeArray())
          .receive("ok", resp => {
            if (resp.success) {
              admin.disable_save_button()
              toastr.success(resp.success)
            } else if (resp.error) {
              toastr.error(resp.error)
            }
        })
      })
      .on('click', 'button.refresh', function(e) {
        let page = $(this).closest('section').data('page')
        $('a.admin-link[data-link="' + page + '"]').click()
      })
      .on('click', '.list-view.channel-settings span[data-edit]', (e) => {
        let channel_id = $(e.currentTarget).closest('[data-id]').data('id')
        this.userchan_push('edit', {channel_id: channel_id, field: $(e.currentTarget).data('edit')})
      })
      .on('click', '.channel-settings button.save', e => {
        let channel_id = $(e.currentTarget).closest('[data-id]').data('id')
        let params = $('.channel-settings form').serializeArray()
        this.userchan_push('save', {channel_id: channel_id, params: params})
      })
      .on('click', '.channel-settings button.cancel', e => {
        let channel_id = $(e.currentTarget).closest('[data-id]').data('id')
        this.userchan_push('cancel', {channel_id: channel_id})
      })
  }

  userchan_push(action, params) {
    userchan.push('admin:channel-settings:' + action, params)
      .receive("ok", resp => {
        if (resp.html) {
          $('.content.channel-settings').replaceWith(resp.html)
        }

      })
      .receive("error", resp => {
        this.do_toastr(resp)
      })
  }
  do_toastr(resp) {
    if (resp.success) {
      toastr.success(resp.success)
    } else if (resp.error) {
      toastr.error(resp.error)
    } else if (resp.warning) {
      toastr.warning(resp.warning)
    }

  }
}

export default Admin
