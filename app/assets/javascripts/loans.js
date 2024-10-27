function toggleModal(loanId) {
    const modal = document.getElementById(`adjustModal-${loanId}`);
    modal.classList.toggle("hidden");
}

function toggleRepayModal(loanId) {
    const modal = document.getElementById(`repayModal-${loanId}`);
    modal.classList.toggle("hidden");
}


