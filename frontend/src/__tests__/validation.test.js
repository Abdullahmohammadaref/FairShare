import { describe, it, expect } from 'vitest'
import { generateTransferPlan } from '@utils/transferPlanAlgorithm.js'
import { createRouter, createWebHistory } from 'vue-router'

import { mount } from '@vue/test-utils'
import App from '../App.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [],
})

describe('App', () => {
  it('mounts renders properly', () => {
    const wrapper = mount(App, {
      global: {
        plugins: [router],
      },
    })
    expect(wrapper.exists()).toBe(true)
  })
})


describe('Transfer plan generator algorithm', () => {
  it('Should settle all members\' debts with 6 transfers steps', () => {
    const members = [
      { name: 'John', moneyOwnedOrNeeded: -265 },
      { name: 'Alex', moneyOwnedOrNeeded: 567 },
      { name: 'Fred', moneyOwnedOrNeeded: 400 },
      { name: 'Sara', moneyOwnedOrNeeded: -830 },
      { name: 'Peter', moneyOwnedOrNeeded: 1009 },
      { name: 'Emma', moneyOwnedOrNeeded: -901 },
      { name: 'James', moneyOwnedOrNeeded: 20}
    ]

    const returnedResult = generateTransferPlan(members)

    expect(returnedResult.length).toBe(6)

    expect(returnedResult[0].payer.name).toBe('Emma')
    expect(returnedResult[0].reciver.name).toBe('Peter')
    expect(returnedResult[0].amount).toBe(901)

    expect(returnedResult[1].payer.name).toBe('Sara')
    expect(returnedResult[1].reciver.name).toBe('Alex')
    expect(returnedResult[1].amount).toBe(567)

    expect(returnedResult[2].payer.name).toBe('John')
    expect(returnedResult[2].reciver.name).toBe('Fred')
    expect(returnedResult[2].amount).toBe(265)

    expect(returnedResult[3].payer.name).toBe('Sara')
    expect(returnedResult[3].reciver.name).toBe('Fred')
    expect(returnedResult[3].amount).toBe(135)

    expect(returnedResult[4].payer.name).toBe('Sara')
    expect(returnedResult[4].reciver.name).toBe('Peter')
    expect(returnedResult[4].amount).toBe(108)

    expect(returnedResult[5].payer.name).toBe('Sara')
    expect(returnedResult[5].reciver.name).toBe('James')
    expect(returnedResult[5].amount).toBe(20)
  })
})
