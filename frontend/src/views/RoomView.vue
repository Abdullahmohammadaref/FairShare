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
  <main>
    <header>
      <h1>FairShare</h1>
      <button type="button" @click="toggleAddMemberForm">
        <img src="../assets/images/add.svg" alt="add" />
        <span>Add Member</span>
      </button>
    </header>

    <div id="body">
      <section id="membersSection">
        <h2>Members and expenses</h2>

        <form id="membersForm" @submit.prevent>
          <ul>
            <li id="member" v-for="member in membersItems.updatedMembers" :key="member.id">
              <div class="row">
                <input
                  id="memberNameField"
                  class="nameField"
                  @change="updateMemberName(member)"
                  type="text"
                  v-model="member.name"
                  required
                />
                <p id="moneyOwnedOrNeededSmallerThanZero" v-if="member.moneyOwnedOrNeeded < 0">
                  {{ member.moneyOwnedOrNeeded }}
                </p>
                <p id="moneyOwnedOrNeededGraterThanZero" v-if="member.moneyOwnedOrNeeded > 0">
                  {{ member.moneyOwnedOrNeeded }}
                </p>
                <p id="moneyOwnedOrNeededEqualToZero" v-if="member.moneyOwnedOrNeeded === 0">
                  {{ member.moneyOwnedOrNeeded }}
                </p>
                <button type="button" @click="toggleAddItemForm(member.id)">Add Item</button>
                <button type="button" @click="deleteMember(member)">
                  <img src="../assets/images/trash.svg" alt="delete" />
                </button>
              </div>

              <form id="memberItemsForm" @submit.prevent>
                <ul>
                  <li v-for="memberItem in member.memberItems" :key="memberItem.id">
                    <div class="row">
                      <input
                        id="memberItemNameField"
                        class="nameField"
                        @change="updateMemberItemName(memberItem)"
                        type="text"
                        v-model="memberItem.name"
                        required
                      />
                      <input
                        id="memberItemPriceField"
                        class="priceField"
                        @change="updateMemberItemPrice(memberItem)"
                        type="number"
                        v-model="memberItem.price"
                        step="0.01"
                        min="0"
                        required
                      />
                      <button type="button" @click="deleteMemberItem(memberItem)">
                        <img src="../assets/images/trash.svg" alt="delete" />
                      </button>
                    </div>

                    <form id="memberItemConsumptionsForm" @submit.prevent>
                      <ul>
                        <li
                          v-for="itemConsumption in memberItem.memberItemConsumptions"
                          :key="itemConsumption.id"
                        >
                          <div class="row">
                            <label :for="itemConsumption.member_id"
                              >{{
                                members.find(
                                  (memberInMembers) =>
                                    memberInMembers.id === itemConsumption.member_id,
                                )?.name
                              }}:</label
                            >
                            <input
                              class="priceField"
                              :id="itemConsumption.member_id"
                              @change="updateConsumptionProportion(itemConsumption)"
                              type="number"
                              v-model="itemConsumption.proportion"
                              :value="itemConsumption.proportion"
                              step="0.01"
                              min="0"
                              required
                            />
                            <p id="proportionSum">
                              / {{ memberItem.itemConsumptionProportionsSum }}
                            </p>
                            <p id="valueConsumed">{{ itemConsumption.valueConsumed }}</p>
                          </div>
                        </li>
                      </ul>
                    </form>
                  </li>
                </ul>
              </form>
            </li>
          </ul>
        </form>
      </section>

      <section id="planSection">
        <h2>Payment plan</h2>
        <ul>
          <li
            id="planItem"
            v-for="transfer in membersItems.transferPlan"
            :key="`${transfer.payer.id} - ${transfer.reciver.id}`"
          >
            <p id="payer">{{ transfer.payer.name }}</p>
            send
            <p id="amount">{{ transfer.amount }}</p>
            to
            <p id="reciver">{{ transfer.reciver.name }}</p>
          </li>
        </ul>
      </section>
    </div>
  </main>
</template>

<style scoped>
main {
  box-sizing: border-box;
  width: 100%;
  height: 100%;
  align-items: center;
  justify-content: center;
  display: flex;
  flex-direction: column;
  gap: 1rem;

}

header {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-around;
  background-color: #f0f4f2;
  border-radius: 0.7rem;
  width: 100%;
}

#body {
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  justify-content: center;

  width: 100%;
  height: 100%;
  box-sizing: border-box;
  padding: 0 2rem;
}

#membersSection {
  display: flex;
  flex-direction: column;
  justify-content: center;
}
#planSection {
  display: flex;
  flex-direction: column;
  justify-content: center;
}

button {
  background-color: #7b9669;
  border-radius: 1rem;
  border: none;
  width: auto;
  padding: 0.5rem 0.6rem;
  font-weight: bold;
  font-size: 0.8rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: transform 0.1s ease-in-out;
}
button:hover{
  transform: scale(1.1);
}

input {
  background-color: #e2e8e4;
  border: hsla(0, 0%, 0%, 0.1) 1px solid;
  border-radius: 0.3rem;
  padding: 0.5rem;
  height: 2rem;
  box-sizing: border-box;
}

li {
  display: flex;
  flex-direction: column;

  gap: 1rem;
  margin: 1rem;
  border: hsla(0, 0%, 0%, 0.1) 1px solid;

  background-color: #f0f4f2;
  border-radius: 0.7rem;
}
h2 {
  margin: 1rem;
}

#planItem {
  display: flex;
  flex-direction: row;
  padding: 1rem;
}

section {
  display: flex;
  justify-content: center;
  width: 100%;
}

.row {
  display: flex;
  gap: 0.6rem;

  padding: 0.5rem;
  background-color: #e2e8e4;
  border-radius: 0.7rem;
}

#member {
  margin: 0;
}

#valueConsumed {
  background-color: #7b9669;
  border-radius: 0.7rem;
  padding: 0.2rem 0.6rem 0.2rem 0.6rem;
}
#proportionSum {
  color: hsla(0, 0%, 50%, 0.5);
  background-color: #e2e8e4;
}
#moneyOwnedOrNeededSmallerThanZero {
  background-color: #991b1b;
  border-radius: 0.7rem;
  padding: 0.3rem 0.7rem 0.3rem 0.7rem;
}
#moneyOwnedOrNeededGraterThanZero {
  background-color: #7b9669;
  border-radius: 0.7rem;
  padding: 0.3rem 0.7rem 0.3rem 0.7rem;
}
#moneyOwnedOrNeededEqualToZero {
  background-color: gray;
  border-radius: 0.7rem;
  padding: 0.3rem 0.7rem 0.3rem 0.7rem;
}
#payer {
  color: #991b1b;
  background-color: #f0f4f2;
}
#reciver {
  color: green;
  background-color: #f0f4f2;
}
#amount {
  color: gray;
  background-color: #f0f4f2;
}

@media screen and (min-width: 0px) and (max-width: 480px) {
  #body {
    flex-direction: column;
  }
  .nameField {
    width: 8rem;
  }
  .priceField {
    width: 7rem;
  }
}
@media screen and (min-width: 481px) and (max-width: 768px) {
  #body {
    flex-direction: column;
  }
}
@media screen and (min-width: 769px) and (max-width: 1280px) {
}
@media screen and (min-width: 1280px) {
}
</style>
