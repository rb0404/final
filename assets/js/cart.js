document.addEventListener('DOMContentLoaded', () => {
    const cartContainer = document.getElementById('cart-container');
    const totalPriceElement = document.querySelector('.total-price');
    const checkoutButton = document.querySelector('.checkout');
    
    function updateTotal() {
        const cartItems = document.querySelectorAll('.cart-item');
        let total = 0;
        cartItems.forEach(item => {
            const priceElement = item.querySelector('.item-price');
            const quantityElement = item.querySelector('.item-quantity');
            const price = parseFloat(priceElement.textContent.replace('NT$', '').trim());
            const quantity = parseInt(quantityElement.value);
            total += price * quantity;
        });
        totalPriceElement.textContent = `NT$${total}`;
    }

    cartContainer.addEventListener('input', (event) => {
        if (event.target.classList.contains('item-quantity')) {
            updateTotal();
        }
    });

    cartContainer.addEventListener('click', (event) => {
        if (event.target.classList.contains('remove-item')) {
            event.target.parentElement.remove();
            updateTotal();
        }
    });

    checkoutButton.addEventListener('click', () => {
        const cartItems = document.querySelectorAll('.cart-item');
        if (cartItems.length === 0) {
            alert('購物車是空的！');
        } else {
            alert('結帳成功！');
        }
    });

    updateTotal();
});
