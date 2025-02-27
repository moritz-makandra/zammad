<!-- Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import { SelectOption } from '@shared/components/Form/fields/FieldSelect/types'
import CommonTicketStateIndicator from '@shared/components/CommonTicketStateIndicator/CommonTicketStateIndicator.vue'
import { computed } from 'vue'
import { i18n } from '@shared/i18n'

const props = defineProps<{
  option: SelectOption
  selected: boolean
  multiple?: boolean
  noLabelTranslate?: boolean
}>()

const emit = defineEmits<{
  (e: 'select', option: SelectOption): void
}>()

const select = (option: SelectOption) => {
  emit('select', option)
}

const label = computed(() => {
  const { option } = props
  if (props.noLabelTranslate) {
    return option.label
  }

  return i18n.t(option.label, ...(option.labelPlaceholder || []))
})
</script>

<template>
  <div
    :class="{
      'pointer-events-none': option.disabled,
    }"
    :tabindex="option.disabled ? '-1' : '0'"
    :aria-selected="selected"
    class="flex h-[58px] cursor-pointer items-center self-stretch py-5 px-4 text-base leading-[19px] text-white first:rounded-t-xl last:rounded-b-xl focus:bg-blue-highlight focus:outline-none"
    role="option"
    @click="select(option)"
    @keypress.space="select(option)"
  >
    <CommonIcon
      v-if="multiple"
      :class="{
        '!text-white': selected,
        'opacity-30': option.disabled,
      }"
      size="base"
      :name="selected ? 'checked-yes' : 'checked-no'"
      class="mr-3 text-white/50"
    />
    <CommonTicketStateIndicator
      v-if="option.status"
      :status="option.status"
      :label="option.label"
      :class="{
        'opacity-30': option.disabled,
      }"
      class="mr-[11px]"
    />
    <CommonIcon
      v-else-if="option.icon"
      :name="option.icon"
      size="tiny"
      :class="{
        '!text-white': selected,
        'opacity-30': option.disabled,
      }"
      class="mr-[11px] text-white/80"
    />
    <span
      :class="{
        'font-semibold !text-white': selected,
        'opacity-30': option.disabled,
      }"
      class="grow text-white/80"
    >
      {{ label || option.value }}
    </span>
    <CommonIcon
      v-if="!multiple && selected"
      :class="{
        'opacity-30': option.disabled,
      }"
      size="tiny"
      name="check"
    />
  </div>
</template>
