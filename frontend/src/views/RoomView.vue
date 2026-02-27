<script setup>
import { supabase } from '@utils/supabase'
import NewMemberForm from '@src/components/RoomView/NewMemberForm.vue'
import NewItemForm from '@src/components/RoomView/NewItemForm.vue'
import { ref } from 'vue'
import { onMounted, onUnmounted, computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

let membersChannel
let itemsChannel

const isAddMemberFormVisible = ref(false)
const isAddItemFormVisible = ref(false)
const addItemFormMember = ref(null)

const members = ref([])
const items = ref([])

const toggleAddMemberForm = () => {
  isAddMemberFormVisible.value = !isAddMemberFormVisible.value
}
const toggleAddItemForm = (memberId = null) => {
  isAddItemFormVisible.value = !isAddItemFormVisible.value
  addItemFormMember.value = memberId
}

onMounted(async () => {
  // Populate room members list from the database when the component is first loaded
  try {
    const { data, error } = await supabase
      .from('members')
      .select()
      .eq('room_id', route.params.roomId)
      .order('name', { ascending: true })

    if (error) {
      throw error
    }
    members.value = data.map((member) => ({ ...member, items: [] }))
  } catch (error) {
    alert(error.message)
  }
  // Populate members items list from the database when the component is first loaded
  try {
    const { data, error } = await supabase
      .from('items')
      .select()
      .in('payer_id', members.value.map((member) => member.id))
      .order('name', { ascending: true })

    if (error) {
      throw error
    }
    items.value = data
  } catch (error) {
    alert(error.message)
  }
  console.log(1)


  // Creating a channel using supabase that always gets updates form the members table in real time
  membersChannel = supabase
    .channel(`room:${route.params.roomId}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'members',
        filter: `room_id=eq.${route.params.roomId}`,
      },
      (payload) => {
        if (payload.eventType === 'INSERT') {
          members.value.push(payload.new)
        } else if (payload.eventType === 'UPDATE') {
          members.value = members.value.map((member) => {
            if (member.id === payload.new.id) {
              return payload.new
            }
            return member
          })
        } else if (payload.eventType === 'DELETE') {
          members.value = members.value.filter((member) => (member.id !== payload.old.id))
        }
      },
    )
    .subscribe()

  // Creating a channel using supabase that always gets updates form the items table in real time
  itemsChannel = supabase
    .channel(`room:${route.params.roomId}:membersItems`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'items',
        filter: `payer_id=in.${members.value.map((member) => member.id)}`,
      },
      (payload) => {
        if (payload.eventType === 'INSERT') {
          items.value.push(payload.new)
        } else if (payload.eventType === 'UPDATE') {
          items.value = items.value.map((item) => {
            if (item.id === payload.new.id) {
              return payload.new
            }
            return item
          })
        } else if (payload.eventType === 'DELETE') {
          items.value = items.value.filter((item) => item.id !== payload.old.id)
        }
      },
    )
    .subscribe()
})

onUnmounted(() => {
  if (membersChannel) {
    supabase.removeChannel(membersChannel)
  }
  if (itemsChannel) {
    supabase.removeChannel(itemsChannel)
  }
})

// Always update this variable to store members and their items
const membersItems = computed(() => {
  return members.value.map((member) => {
    const memberItems = items.value.filter((item) => item.payer_id === member.id)
    return { ...member, memberItems }
  })
})
</script>

<template>
  <main>
    <NewMemberForm @closeForm="toggleAddMemberForm" :isFormVisible="isAddMemberFormVisible" />
    <NewItemForm
      @closeForm="toggleAddItemForm"
      :isFormVisible="isAddItemFormVisible"
      :memberId="addItemFormMember"
    />
    <button @click="toggleAddMemberForm">New member</button>
    <ul>
      <li v-for="member in membersItems" :key="member.id">
        {{ member.name }}
        <button @click="toggleAddItemForm(member.id)">New Item</button>
        <ul>np
          <li v-for="item in member.memberItems" :key="item.id">
            {{ item.name }}
          </li>
        </ul>
      </li>
    </ul>
  </main>
</template>

<style scoped>
main {
  position: relative;
  width: 100%;
  height: 100%;
}
</style>
