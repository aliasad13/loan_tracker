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


