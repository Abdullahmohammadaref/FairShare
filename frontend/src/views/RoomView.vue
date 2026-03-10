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
  const updatedMembers = members.value.map((member) => {
    let totalMoneySpent = 0
    let totalValueConsumed = 0
    let moneyOwnedOrNeeded = 0

    const filteredMemberItems = items.value.filter((item) => item.payer_id === member.id)

    const memberItems = filteredMemberItems.map((memberItem) => {
      const itemConsumptionProportionsSum = ref(0)

      const filteredMemberItemConsumptions = itemConsumptions.value.filter(
        (itemConsumption) => itemConsumption.item_id === memberItem.id,
      )

      filteredMemberItemConsumptions.forEach((itemConsumption) => {
        itemConsumptionProportionsSum.value += itemConsumption.proportion
      })

      const memberItemConsumptions = filteredMemberItemConsumptions.map((memberItemConsumption) => {
        let valueConsumed = 0
        if (itemConsumptionProportionsSum.value > 0) {
          valueConsumed = parseFloat(
            (
              (memberItemConsumption.proportion / itemConsumptionProportionsSum.value) *
              memberItem.price
            ).toFixed(2),
          )
        }
        return { ...memberItemConsumption, valueConsumed }
      })

      return { ...memberItem, memberItemConsumptions, itemConsumptionProportionsSum }
    })

    memberItems.forEach((memberItem) => {
      totalMoneySpent += memberItem.price
    })

    return { ...member, memberItems, totalMoneySpent, totalValueConsumed, moneyOwnedOrNeeded }
  })

  const consumptions = []
  for (const member of updatedMembers) {
    for (const memberItem of member.memberItems) {
      consumptions.push(memberItem.memberItemConsumptions)
    }
  }

  for (const member of updatedMembers) {
    for (const itemConsumptions of consumptions) {
      const memberConsumptions = itemConsumptions.filter(
        (consumption) => consumption.member_id === member.id,
      )

      for (const consumption of memberConsumptions) {
        member.totalValueConsumed += consumption.valueConsumed
      }
    }
    member.moneyOwnedOrNeeded = parseFloat(
      (member.totalMoneySpent - member.totalValueConsumed).toFixed(2),
    )
  }

  // Transfer plan algorithm
  const transferPlan = []
  // 1- Create and populate arrays for both payers and payees
  const payers = []
  const recivers = []
  for (const member of updatedMembers) {
    if (member.moneyOwnedOrNeeded > 0) {
      recivers.push({ ...member })
    } else {
      payers.push({ ...member })
    }
  }
  // 2- Sort members inside the arrays in ascending order by the absolute value of their totalValueConsumed.
  payers.sort((a, b) => -(a.moneyOwnedOrNeeded - b.moneyOwnedOrNeeded))
  recivers.sort((a, b) => a.moneyOwnedOrNeeded - b.moneyOwnedOrNeeded)

  // 3- Keep making the highest in debt send to the highest in credit
  while (true) {
    if (payers.length === 0 || recivers.length === 0) {
      break
    } else if (
      -payers[payers.length - 1].moneyOwnedOrNeeded >
      recivers[recivers.length - 1].moneyOwnedOrNeeded
    ) {
      transferPlan.push({
        payer: payers[payers.length - 1],
        reciver: recivers[recivers.length - 1],
        amount: parseFloat(recivers[recivers.length - 1].moneyOwnedOrNeeded.toFixed(2)),
      })
      payers[payers.length - 1].moneyOwnedOrNeeded +=
        recivers[recivers.length - 1].moneyOwnedOrNeeded
      payers.sort((a, b) => -(a.moneyOwnedOrNeeded - b.moneyOwnedOrNeeded))
      recivers.pop()
    } else if (
      -payers[payers.length - 1].moneyOwnedOrNeeded <
      recivers[recivers.length - 1].moneyOwnedOrNeeded
    ) {
      transferPlan.push({
        payer: payers[payers.length - 1],
        reciver: recivers[recivers.length - 1],
        amount: parseFloat(-payers[payers.length - 1].moneyOwnedOrNeeded),
      })
      recivers[recivers.length - 1].moneyOwnedOrNeeded -=
        -payers[payers.length - 1].moneyOwnedOrNeeded
      recivers.sort((a, b) => a.moneyOwnedOrNeeded - b.moneyOwnedOrNeeded)
      payers.pop()
    } else {
      transferPlan.push({
        payer: payers[payers.length - 1],
        reciver: recivers[recivers.length - 1],
        amount: parseFloat(recivers[recivers.length - 1].moneyOwnedOrNeeded.toFixed(2)),
      })
      payers.pop()
      recivers.pop()
    }
  }

  return { updatedMembers, transferPlan }
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
const updateMemberName = async (member) => {
  try {
    const { error } = await supabase
      .from('Members')
      .update({ name: member.name })
      .eq('id', member.id)
      .select()
    if (error) {
      throw error
    }
  } catch (error) {
    alert(error.message)
  }
}

const deleteMember = async (member) => {
  try {
    const { error } = await supabase.from('Members').delete().eq('id', member.id)
    if (error) {
      throw error
    }
  } catch (error) {
    alert(error.message)
  }
}

const updateMemberItemName = async (memberItem) => {
  try {
    const { error } = await supabase
      .from('Items')
      .update({ name: memberItem.name })
      .eq('id', memberItem.id)
      .select()
    if (error) {
      throw error
    }
  } catch (error) {
    alert(error.message)
  }
}

const updateMemberItemPrice = async (memberItem) => {
  try {
    const { error } = await supabase
      .from('Items')
      .update({ price: memberItem.price })
      .eq('id', memberItem.id)
      .select()
    if (error) {
      throw error
    }
  } catch (error) {
    alert(error.message)
  }
}

const deleteMemberItem = async (memberItem) => {
  try {
    const { error } = await supabase.from('Items').delete().eq('id', memberItem.id)
    if (error) {
      throw error
    }
  } catch (error) {
    alert(error.message)
  }
}
</script>

<template>
  <main>
    <NewMemberForm
      @closeForm="toggleAddMemberForm"
      :isFormVisible="isAddMemberFormVisible"
      :membersItems="membersItems.updatedMembers"
    />
    <NewItemForm
      @closeForm="toggleAddItemForm"
      :isFormVisible="isAddItemFormVisible"
      :memberId="addItemFormMember"
      :members="members"
    />
    <button type="button" @click="toggleAddMemberForm">New member</button>
    <form @submit.prevent>
      <ul>
        <li v-for="member in membersItems.updatedMembers" :key="member.id">
          <button type="button" @click="deleteMember(member)">x</button>
          <input @change="updateMemberName(member)" type="text" v-model="member.name" required /> :
          {{ member.moneyOwnedOrNeeded }}
          <button type="button" @click="toggleAddItemForm(member.id)">New Item</button>
          <form @submit.prevent>
            <ul>
              <li v-for="memberItem in member.memberItems" :key="memberItem.id">
                <button type="button" @click="deleteMemberItem(memberItem)">x</button>
                <input
                  @change="updateMemberItemName(memberItem)"
                  type="text"
                  v-model="memberItem.name"
                  required
                />
                :
                <input
                  @change="updateMemberItemPrice(memberItem)"
                  type="number"
                  v-model="memberItem.price"
                  step="0.01"
                  min="0"
                  required
                />
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
                      / {{ memberItem.itemConsumptionProportionsSum }} :
                      {{ itemConsumption.valueConsumed }}
                    </li>
                  </ul>
                </form>
              </li>
            </ul>
          </form>
          <hr />
        </li>
      </ul>
    </form>
    <hr />
    <ul>
      <li
        v-for="transfer in membersItems.transferPlan"
        :key="`${transfer.payer.id} - ${transfer.reciver.id}`"
      >
        {{ transfer.payer.name }} --{{ transfer.amount }}--> {{ transfer.reciver.name }}
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
