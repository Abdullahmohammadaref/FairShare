<script setup>
import { ref } from 'vue'
import { supabase } from '@utils/supabase'

defineProps({
  isFormVisible: {
    type: Boolean,
    required: true,
  },
  memberId: {
    type: Number,
    required: true,
  },
})

const itemName = ref('')

// Adds an item in the database for the current member
const addItem = async (memberId) => {
  try {
    const { error } = await supabase
      .from('items')
      .insert({ name: itemName.value, payer_id: memberId })
      .select()

    if (error) {
      throw error
    }
    itemName.value = ''
  } catch (error) {
    alert(error.message)
  }
}
</script>

<template>
  <div id="form-overlay" :class="{ isFormVisible: isFormVisible }">
    <div id="form-background" @click="$emit('closeForm')"></div>
    <form id="form" @submit.prevent="addItem(memberId)">
      <h1>New item</h1>
      <input type="text" placeholder="name" v-model="itemName" required />
      <button type="submit">Submit</button>
    </form>
  </div>
</template>

<style scoped>
#form-overlay {
  position: fixed;
  width: 100%;
  height: 100%;
  z-index: 5;
  pointer-events: none;
  visibility: hidden;
}

#form-overlay.isFormVisible {
  pointer-events: auto;
  visibility: visible;
}

#form-overlay.isFormVisible #form {
  opacity: 1;
}

#form-background {
  position: absolute;
  background-color: black;
  width: 100%;
  height: 100%;
  opacity: 0;
  transition:
    opacity 0.18s ease-in-out,
    visibility 0.18s,
    color 0.18s ease-in-out;
}

#form-overlay.isFormVisible #form-background {
  opacity: 0.7;
}

#form {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: flex;
  flex-direction: column;
  gap: 1.1rem;
  padding: 2.5rem;
  border-radius: 0.5rem;
  background-color: white;
  max-width: 40%;
  box-shadow: 0 2px 10px hsla(0, 0%, 0%, 0.4);
  opacity: 0;
  transition:
    opacity 0.18s ease-in-out,
    visibility 0.18s;
}
</style>
