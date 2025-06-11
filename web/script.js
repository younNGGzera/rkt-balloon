$(document).ready(function () {
    let uiOpen = false;

    window.addEventListener("message", (event) => {
        if (event.data.action === "openUI") {
            openUI(event.data.locations);
        }
    });

    function openUI(locations) {
        uiOpen = true;
        $(".container").show();
        $(".container").empty();

        locations.forEach((location) => {
            const { id, combustivel, desgaste, isOut } = location;

            let buttonText = isOut ? "Store" : "Take out";

            $(".container").append(`
                <div class="location" id="location-${id}">
                    <button class="button desgaste-button" data-id="${id}">Worn</button>
                    <span class="percentage desgaste-percentage" data-id="${id}">${desgaste}%</span>
                    
                    <!-- Mantendo o contêiner .toggle-buttons -->
                    <div class="toggle-buttons">
                        <button class="button toggle-vehicle" data-id="${id}">${buttonText}</button>
                    </div>
                </div>
            `);
        });
    }

    function closeUI() {
        uiOpen = false;
        $(".container").hide();
        $(".container").empty();
        $.post(`https://${GetParentResourceName()}/close-callback`, JSON.stringify({}));
    }


    $(document).on('click', '.desgaste-button', function () {
        const id = $(this).data("id");
        $.post(`https://${GetParentResourceName()}/degrade-callback`, JSON.stringify({ id }), null, 'json');
    });

    $(document).on('click', '.toggle-vehicle', function () {
        const button = $(this);
        const id = button.data("id");
        const currentText = button.text();

        if (currentText === "Take out") {
            $.post(`https://${GetParentResourceName()}/outVeh-callback`, JSON.stringify({ id }), null, 'json');
            button.text("Store");
        } else {
            $.post(`https://${GetParentResourceName()}/storeVeh-callback`, JSON.stringify({ id }), null, 'json');
            button.text("Take out");
        }
    });

    $(document).on("keydown", function (e) {
        if (e.key === "Escape" && uiOpen) {
            closeUI();
        }
    });
});
