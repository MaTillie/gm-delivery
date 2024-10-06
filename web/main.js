// Retour au client lua
function callLuaFunction(data) {
    fetch(`https://${GetParentResourceName()}/nuiCallback`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).then(resp => resp.json()).then(resp => {
        console.log('Réponse Lua:', resp);
    }).catch(error => {
        console.error('Erreur lors de l\'appel Lua:', error);
    });
}

function closeMenu() {
    document.getElementById('ticket').style.display = 'none'; 
    callLuaFunction({ action: 'closeMenu', param: 'someValue' });
}

$(document).ready(function () {
    window.addEventListener("message", (event) => {
      const eventData = event.data;

      switch (eventData.action) {
        case "openTicket":
        console.log("openTicket :" )
        // Vider la liste des commandes
        const orderList = document.getElementById('orderList');
        orderList.innerHTML = '';

        // Ajouter les items à la liste
        eventData.data.items.forEach(item => {
            const listItem = document.createElement('li');
            listItem.textContent = `${item.name}  ${item.amount}`;  
            listItem.setAttribute('id', item.cl);    
                    
            orderList.appendChild(listItem);
        });

        // Afficher le ticket
        document.getElementById('ticket').style.display = 'block';
        break;
        default:
          break;
      }
    });
  });




