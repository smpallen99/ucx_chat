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
      save.parent().prepend('<button class="button danger discard"><i class="icon-send"></i><span>Cancel</span></button>')
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
    $('body').on('click', 'button.discard', function() {
      // admin.disable_save_button()
      $('a.admin-link[data-link="info"]').click()
    })
    $('body').on('change', '.admin-settings form input', function(e) {
      let target = e.currentTarget
      admin.enable_save_button()
      let reset = `<button text='Reset' data-setting="${target.getAttribute('name')}" class="reset-setting button danger">${reset_i}</button>`
      $(this).closest('.input-line').addClass('setting-changed') //.append(reset)
    })
    $('body').on('keyup keypress paste', '.admin-settings form input', function(e) {
      admin.enable_save_button()
      $(this).closest('.input-line').addClass('setting-changed') //.append(reset)
    })
    $('body').on('change', '.permissions-manager [type="checkbox"]', function(e, t) {
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
    $('body').on('click', '.page-settings .section button.expand', function(e) {
      e.preventDefault()
      $(this)
        .addClass('collapse')
        .removeClass('expand')
        .first().html('Collapse')
        .closest('.section-collapsed')
        .removeClass('section-collapsed')
    })
    $('body').on('click', '.page-settings .section button.collapse', function(e) {
      e.preventDefault()
      $(this)
        .removeClass('collapse')
        .addClass('expand')
        .first().html('Expand')
        .closest('.section-title')
        .parent()
        .addClass('section-collapsed')
    })
    $('body').on('click', '.admin-settings button.save', function(e) {
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
    $('body').on('click', 'button.refresh', function(e) {
      let page = $(this).closest('section').data('page')
      $('a.admin-link[data-link="' + page + '"]').click()
    })


  }
}

export default Admin
