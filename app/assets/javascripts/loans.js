function toggleModal(loanId) {
    const modal = document.getElementById(`adjustModal-${loanId}`);
    if (modal.classList.contains('hidden')) {
        modal.classList.remove('hidden');
        document.body.style.overflow = 'hidden'; // Prevent scrolling

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                toggleRepayModal(loanId);
            }
        });

        modal.addEventListener('click', function(e) {
            if (e.target === modal.firstElementChild) {
                toggleRepayModal(loanId);
            }
        });
    } else {
        modal.classList.add('hidden');
        document.body.style.overflow = '';
    }
}

function toggleRepayModal(loanId) {
    const modal = document.getElementById(`repayModal-${loanId}`);

    if (modal.classList.contains('hidden')) {
        modal.classList.remove('hidden');
        document.body.style.overflow = 'hidden'; // Prevent scrolling

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                toggleRepayModal(loanId);
            }
        });

        modal.addEventListener('click', function(e) {
            if (e.target === modal.firstElementChild) {
                toggleRepayModal(loanId);
            }
        });
    } else {
        modal.classList.add('hidden');
        document.body.style.overflow = '';
    }
}


function toggleRepayModal(loanId, walletBalance) {
    const modal = document.getElementById(`repayModal-${loanId}`);
    const isHidden = modal.classList.contains('hidden');

    if (isHidden) {
        modal.classList.remove('hidden');
        validatePaymentAmount(loanId, walletBalance);
    } else {
        modal.classList.add('hidden');
    }
}

document.addEventListener('turbolinks:load', () => {
    const modals = document.querySelectorAll('[id^="repayModal-"]');

    modals.forEach((modal) => {
        const loanId = modal.id.split('-')[1];
        const walletBalance = parseFloat(document.querySelector(`#user-wallet-balance-${loanId}`).textContent);

        validatePaymentAmount(loanId, walletBalance);
    });
});

function validatePaymentAmount(loanId, walletBalance) {
    const input = document.getElementById(`payment-amount-${loanId}`);
    const errorMessage = document.getElementById(`error-message-${loanId}`);
    const submitButton = document.querySelector(`#repay-form-${loanId} input[type="submit"]`);

    if (parseFloat(input.value) > walletBalance) {
        errorMessage.classList.remove('hidden');
        submitButton.disabled = true;
    } else {
        errorMessage.classList.add('hidden');
        submitButton.disabled = false;
    }
}

