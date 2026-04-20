document.addEventListener('DOMContentLoaded', function() {
    const fetchModulesBtn = document.getElementById('fetchModules');
    const fetchDataBtn = document.getElementById('fetchData');
    const containerOutput = document.getElementById('containerOutput');
    const dataOutput = document.getElementById('dataOutput');

    fetchModulesBtn.addEventListener('click', function() {
        const args = document.getElementById('args').value;
        fetch(`http://localhost:3000/get-file-list?args=${encodeURIComponent(args)}`)
            .then(response => response.json())
            .then(data => {
                containerOutput.innerHTML = `<pre>${data.stdout || data.stderr}</pre>`;
            })
            .catch(error => {
                containerOutput.innerHTML = `<pre>Error: ${error.message}</pre>`;
            });
    });

    fetchDataBtn.addEventListener('click', function() {
        const sort = document.getElementById('sort').value;
        fetch(`http://localhost:3000/requests/${sort}`)
            .then(response => response.json())
            .then(data => {
                if (data.length > 0) {
                    let html = '<table><tr>';
                    // Create table headers from the keys of the first object
                    Object.keys(data[0]).forEach(key => {
                        html += `<th>${key}</th>`;
                    });
                    html += '</tr>';

                    // Create table rows for each data item
                    data.forEach(item => {
                        html += '<tr>';
                        Object.values(item).forEach(value => {
                            html += `<td>${value}</td>`;
                        });
                        html += '</tr>';
                    });

                    html += '</table>';
                    dataOutput.innerHTML = html;
                } else {
                    dataOutput.innerHTML = '<p>No data found</p>';
                }
            })
            .catch(error => {
                dataOutput.innerHTML = `<pre>Error: ${error.message}</pre>`;
            });
    });
});