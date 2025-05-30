const apiEndpoint = 'https://i5uct33ryknsfn3l4kmm4mbfte0joqvj.lambda-url.us-east-1.on.aws/';


async function updateVisitorCount() {
    try {
        const response = await fetch(apiEndpoint);
        const data = await response.json();
        document.getElementById('visitor-count').innerText = `Visitor Count: ${data.count}`;
    } catch (error) {
        console.error('Error fetching visitor count:', error);
        document.getElementById('visitor-count').innerText = 'Visitor Count: Not Available';
    }
}

updateVisitorCount();

// test t