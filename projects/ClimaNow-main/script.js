"use strict";
window.onload = function () {
    document.body.style.backgroundImage = "url('background.jpg')";
    document.body.style.backgroundSize = 'cover';
    document.body.style.backgroundRepeat = 'no-repeat';
    document.body.style.backgroundPosition = 'center';
};

const enterKey = document.getElementById('location');
enterKey.addEventListener('keydown', function (event) {
    if (event.key === 'Enter') {
        event.preventDefault();
        getWeather();
    }
});

function celusistofar(c) {
    let f = (c * (9 / 5)) + 32;
    return f.toFixed(2);
}

async function getWeather() {
    let userLocation = document.getElementById('location').value;
    const apiKey = '5e64fb5b1f7242e155fcae707578e1a6';
    const srcLink = `https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(userLocation)}&appid=${apiKey}&units=metric`;

    try {
        const response = await fetch(srcLink);
        const locationInfo = await response.json();

        if (response.ok) {
            const tempC = locationInfo.main.temp;
            const tempF = celusistofar(tempC);
            const description = locationInfo.weather[0].description.toLowerCase();

            // Set background based on description or temp
            setSeasonalBackground(description, tempC);

            document.getElementById('resultContainer').innerHTML = `
                <p><strong>${locationInfo.name}</strong></p>
                <p>Current condition: ${description}</p>
                <p>Temperature: ${tempC} °C</p>
                <p>Temperature: ${tempF} °F</p>
            `;
        } else {
            document.getElementById('resultContainer').innerHTML = `<p>Error: ${locationInfo.message}</p>`;
        }
    } catch (error) {
        document.getElementById('resultContainer').innerHTML = `<p>Error: ${error}</p>`;
    }
}

function setSeasonalBackground(description, tempC) {
    let image = '';

    if (description.includes('rain') || description.includes('drizzle') || description.includes('thunderstorm')) {
        image = 'rain.jpg';
    } else if (description.includes('snow')) {
        image = 'wint.jpg';
    } else if (tempC >= 25) {
        image = 'summer.jpg';
    } else if (tempC >= 15 && tempC < 25) {
        image = 'spring.jpeg';
    } else if (tempC >= 5 && tempC < 15) {
        image = 'aut.jpg';
    } else {
        image = 'wint.jpeg';
    }

    document.body.style.backgroundImage = `url('${image}')`;
    document.body.style.backgroundSize = 'cover';
    document.body.style.backgroundRepeat = 'no-repeat';
    document.body.style.backgroundPosition = 'center';
}

