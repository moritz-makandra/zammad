<!-- Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import { useEventListener } from '@vueuse/core'
import { markRaw, shallowRef, TransitionProps } from 'vue'
import { Events } from './manage'
import { DestroyComponentData, PushComponentData } from './types'

const props = defineProps<{
  /**
   * Name of a group of components that will be pushed to with unique ID.
   */
  name: string
  /**
   * Transition, if any.
   */
  transition?: TransitionProps
}>()

const components = shallowRef<PushComponentData[]>([])

useEventListener(
  window,
  Events.Push,
  ({ detail }: CustomEvent<PushComponentData>) => {
    if (detail.name !== props.name) return

    components.value = [
      ...components.value,
      {
        ...detail,
        cmp: markRaw(detail.cmp),
      },
    ]
  },
)

useEventListener(
  window,
  Events.Destroy,
  ({ detail }: CustomEvent<DestroyComponentData>) => {
    if (detail.name !== props.name) return

    if (!detail.id) {
      components.value = []

      return
    }

    components.value = components.value.filter(
      (item) => !(item.name === detail.name && item.id === detail.id),
    )
  },
)
</script>

<template>
  <TransitionGroup v-if="transition" v-bind="transition">
    <template
      v-for="{ cmp, name: cmpName, id, props: cmpProps } in components"
      :key="`${cmpName + id}`"
    >
      <Component :is="cmp" v-bind="cmpProps" />
    </template>
  </TransitionGroup>

  <template v-else-if="!$slots.default">
    <template
      v-for="{ cmp, name: cmpName, id, props: cmpProps } in components"
      :key="`${cmpName + id}`"
    >
      <Component :is="cmp" v-bind="cmpProps" />
    </template>
  </template>

  <slot v-else :components="components" />
</template>
