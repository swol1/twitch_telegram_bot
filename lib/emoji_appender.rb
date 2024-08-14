# frozen_string_literal: true

module EmojiAppender
  EMOJIS = [
    '😀', '😁', '😂', '🤣', '😃', '😄', '😅', '😆', '😉', '😊',
    '😋', '😎', '😍', '😘', '😗', '😙', '😚', '☺️', '🙂', '🤗',
    '🤩', '🤔', '🤨', '😐', '😑', '😶', '🙄', '😏', '🫡', '🫢',
    '😮', '🤐', '😯', '😴', '😌', '😛', '😜', '😝', '🫣', '🫠',
    '🤤', '🙃', '🤑', '😲', '😤', '🤯', '😬', '😱', '😳', '🤪',
    '😵', '😡', '😠', '🤬', '🤧', '😇', '🤠', '🥳', '🥺',
    '🤡', '🤥', '🤫', '🤭', '🧐', '🤓', '😈', '👿', '👹', '👺',
    '💀', '👻', '👽', '👾', '🤖', '😺', '😸', '😹', '😻', '😼',
    '😽', '🙀', '😿', '😾', '🍰', '🍦', '🫶', '🥷', '🧋', '🫦',
    '🍧', '🍨', '🍩', '🍪', '🍫', '🍬', '🍭', '🍮', '🍯', '🍼',
    '☕', '🍵', '🍶', '🍺', '🍻', '🍷', '🍸', '🍹', '🍾', '🍔',
    '🍟', '🍕', '🌭', '🍿', '🍱', '🍲', '🍛', '🍣', '🍙', '🍚',
    '🍘', '🍥', '🍢', '🍡', '🍧', '🍨', '🍦', '🍑', '🍒', '🍓',
    '🥝', '🍍', '🍇', '🍉', '🍌', '🍋', '🍊', '🍏', '🍎', '🍐',
    '🍈', '🥥', '🥑', '🥒', '🥬', '🥦', '🌽', '🥕', '🥔', '🍠',
    '🌰', '🥜', '🍯', '🥐', '🍞', '🥖', '🥨', '🧀', '🥚', '🍳',
    '🥓', '🥩', '🍗', '🍖', '🌭', '🍔', '🍟', '🍕', '🥪', '🌮',
    '🌯', '🥙', '🧆', '🍝', '🍜', '🍲', '🍛', '🍣', '🍱', '🍤',
    '🍙', '🍚', '🍘', '🍥', '🥮', '🍢', '🍡', '🍧', '🍨', '🍦',
    '🥧', '🍰', '🎂', '🧁', '🍮', '🍭', '🍬', '🍫', '🍿', '🍩',
    '🍪', '🥛', '🍼', '☕', '🍵', '🍶', '🍺', '🍻', '🥂', '🍷',
    '🥃', '🍸', '🍹', '🍾', '🧃', '🧉', '🧊'
  ].freeze

  refine String do
    def append_emoji
      "#{self} #{EMOJIS.sample}"
    end
  end
end
