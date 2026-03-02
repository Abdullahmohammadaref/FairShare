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
let itemsConsumptionsChannel

const isAddMemberFormVisible = ref(false)
const isAddItemFormVisible = ref(false)
const addItemFormMember = ref(null)

const members = ref([])
const items = ref([])
const itemConsumptions = ref([])

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
      .from('Members')
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
      .from('Items')
      .select()
      .in(
        'payer_id',
        members.value.map((member) => member.id),
      )
      .order('name', { ascending: true })

    if (error) {
      throw error
    }
    items.value = data
  } catch (error) {
    alert(error.message)
  }
  // Populate items itemConsumptions list from the database when the component is first loaded
  try {
    const { data, error } = await supabase
      .from('ItemConsumptions')
      .select()
      .in(
        'item_id',
        items.value.map((item) => item.id),
      )
      .order('proportion', { ascending: true })

    if (error) {
      throw error
    }
    itemConsumptions.value = data
  } catch (error) {
    alert(error.message)
  }

  // Creating a channel using supabase that always gets updates form the members table in real time
  membersChannel = supabase
    .channel(`room:${route.params.roomId}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'Members',
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
          members.value = members.value.filter((member) => member.id !== payload.old.id)
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
        table: 'Items',
        filter: `room_id=eq.${route.params.roomId}`,
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

  // Creating a channel using supabase that always gets updates form the ItemConsumptions table in real time
  itemsConsumptionsChannel = supabase
    .channel(`room:${route.params.roomId}:itemsConsumptions`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'ItemConsumptions',
        filter: `room_id=eq.${route.params.roomId}`,
      },
      (payload) => {
        if (payload.eventType === 'INSERT') {
          itemConsumptions.value.push(payload.new)
        } else if (payload.eventType === 'UPDATE') {
          itemConsumptions.value = itemConsumptions.value.map((itemConsumption) => {
            if (itemConsumption.id === payload.new.id) {
              return payload.new
            }
            return itemConsumption
          })
        } else if (payload.eventType === 'DELETE') {
          itemConsumptions.value = itemConsumptions.value.filter(
            (itemConsumption) => itemConsumption.id !== payload.old.id,
          )
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
  if (itemsConsumptionsChannel) {
    supabase.removeChannel(itemsConsumptionsChannel)
  }
})

// Always update this variable to store members, items, and items consumptions
const membersItems = computed(() => {
  return members.value.map((member) => {
    const filteredMemberItems = items.value.filter((item) => item.payer_id === member.id)

    const memberItems = filteredMemberItems.map((memberItem) => {
      const memberItemConsumptions = itemConsumptions.value.filter(
        (itemConsumption) => itemConsumption.item_id === memberItem.id,
      )
      return { ...memberItem, memberItemConsumptions }
    })

    return { ...member, memberItems }
  })
})

const updateConsumptionProportion = async (itemConsumption) => {
  try {
    const { error } = await supabase
      .from('ItemConsumptions')
      .update({ proportion: itemConsumption.proportion })
      .eq('id', itemConsumption.id)
      .select()
    if (error) {
      throw error
    }
  } catch (error) {
    alert(error.message)
  }
}

const itemConsumptionProportionsSum = (memberItemConsumptions) => {
  let total = 0
  for (const itemConsumption of memberItemConsumptions) {
    total += itemConsumption.proportion
  }
  return total
}
</script>

<template>
  <main>
    <NewMemberForm
      @closeForm="toggleAddMemberForm"
      :isFormVisible="isAddMemberFormVisible"
      :membersItems="membersItems"
    />
    <NewItemForm
      @closeForm="toggleAddItemForm"
      :isFormVisible="isAddItemFormVisible"
      :memberId="addItemFormMember"
      :members="members"
    />
    <button @click="toggleAddMemberForm">New member</button>
    <ul>
      <li v-for="member in membersItems" :key="member.id">
        {{ member.name }}
        <button @click="toggleAddItemForm(member.id)">New Item</button>
        <ul>
          <li v-for="memberItem in member.memberItems" :key="memberItem.id">
            {{ memberItem.name }}: {{ memberItem.price }}
            <form @submit.prevent>
              <ul>
                <li
                  v-for="itemConsumption in memberItem.memberItemConsumptions"
                  :key="itemConsumption.id"
                >
                  <label :for="itemConsumption.member_id">
                    {{
                      members.find(
                        (memberInMembers) => memberInMembers.id === itemConsumption.member_id,
                      )?.name
                    }}
                  </label>
                  <input
                    :id="itemConsumption.member_id"
                    @change="updateConsumptionProportion(itemConsumption)"
                    type="number"
                    v-model="itemConsumption.proportion"
                    :value="itemConsumption.proportion"
                    step="0.01"
                    min="0"
                    required
                  />
                  / {{ itemConsumptionProportionsSum(memberItem.memberItemConsumptions) }} :
                  {{ ((itemConsumption.proportion / itemConsumptionProportionsSum(memberItem.memberItemConsumptions)) * memberItem.price).toFixed(2) }}
                </li>
              </ul>
            </form>
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
