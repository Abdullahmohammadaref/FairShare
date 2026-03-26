
export function generateTransferPlan(members){
  const transferPlan = []
  // 1- Create and populate arrays for both payers and payees
  const payers = []
  const recivers = []
  for (const member of members) {
    if (member.moneyOwnedOrNeeded > 0) {
      recivers.push({ ...member })
    } else {
      payers.push({ ...member })
    }
  }
  // 2- Sort members inside the arrays in ascending order by the absolute value of their moneyOwnedOrNeeded value.
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
  return transferPlan
}


