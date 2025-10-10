// Global variables
let currentResult = null;
let apiBaseUrl = 'https://spss-parser-api.onrender.com/api'; // Updated for production

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    setupFileUpload();
    loadSavedApiUrl();
    setupEventListeners();
}

function setupEventListeners() {
    // API URL change
    document.getElementById('apiUrl').addEventListener('change', function() {
        apiBaseUrl = this.value.replace(/\/$/, ''); // Remove trailing slash
        localStorage.setItem('spss_api_url', apiBaseUrl);
    });
    
    // File input change
    document.getElementById('fileInput').addEventListener('change', handleFileSelect);
}

function setupFileUpload() {
    const uploadArea = document.getElementById('uploadArea');
    
    // Prevent default drag behaviors
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        uploadArea.addEventListener(eventName, preventDefaults, false);
        document.body.addEventListener(eventName, preventDefaults, false);
    });
    
    // Highlight drop area when dragging over
    ['dragenter', 'dragover'].forEach(eventName => {
        uploadArea.addEventListener(eventName, highlight, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
        uploadArea.addEventListener(eventName, unhighlight, false);
    });
    
    // Handle dropped files
    uploadArea.addEventListener('drop', handleDrop, false);
}

function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
}

function highlight(e) {
    document.getElementById('uploadArea').classList.add('drag-over');
}

function unhighlight(e) {
    document.getElementById('uploadArea').classList.remove('drag-over');
}

function handleDrop(e) {
    const dt = e.dataTransfer;
    const files = dt.files;
    
    if (files.length > 0) {
        processFile(files[0]);
    }
}

function handleFileSelect(e) {
    const files = e.target.files;
    if (files.length > 0) {
        processFile(files[0]);
    }
}

function loadSavedApiUrl() {
    const savedUrl = localStorage.getItem('spss_api_url');
    if (savedUrl) {
        apiBaseUrl = savedUrl;
        document.getElementById('apiUrl').value = savedUrl;
    } else {
        // Set default to Render.com production URL
        document.getElementById('apiUrl').value = 'https://spss-parser-api.onrender.com/api';
    }
}

async function testConnection() {
    const statusDiv = document.getElementById('connectionStatus');
    statusDiv.innerHTML = 'Tester tilkobling...';
    statusDiv.className = 'status-testing';
    
    try {
        const response = await fetch(`${apiBaseUrl}/health`, {
            method: 'GET',
            headers: {
                'Accept': 'application/json'
            }
        });
        
        if (response.ok) {
            const data = await response.json();
            statusDiv.innerHTML = `✅ Tilkobling vellykket - ${data.service || 'SPSS Parser API'}`;
            statusDiv.className = 'status-success';
            
            // Show additional info if available
            if (data.version) {
                statusDiv.innerHTML += ` (v${data.version})`;
            }
        } else {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
    } catch (error) {
        statusDiv.innerHTML = '❌ Tilkobling feilet: ' + error.message;
        statusDiv.className = 'status-error';
        console.error('Connection test failed:', error);
    }
}

function processFile(file) {
    // Validate file
    if (!file.name.toLowerCase().endsWith('.sav')) {
        alert('Vennligst velg en .sav fil');
        return;
    }
    
    // Check file size (50MB limit)
    if (file.size > 52428800) {
        alert('Filen er for stor. Maksimal størrelse er 50MB.');
        return;
    }
    
    // Show file info
    showFileInfo(file);
    
    // Start upload and processing
    uploadFile(file);
}

function showFileInfo(file) {
    const fileInfoDiv = document.getElementById('fileInfo');
    fileInfoDiv.innerHTML = `
        <h3>Valgt fil:</h3>
        <p><strong>Navn:</strong> ${file.name}</p>
        <p><strong>Størrelse:</strong> ${formatFileSize(file.size)}</p>
        <p><strong>Type:</strong> ${file.type || 'application/octet-stream'}</p>
    `;
    fileInfoDiv.classList.remove('hidden');
}

async function uploadFile(file) {
    showProgress(true);
    
    const formData = new FormData();
    formData.append('file', file);
    
    try {
        updateProgress(10, 'Starter opplasting...');
        
        const response = await fetch(`${apiBaseUrl}/parse`, {
            method: 'POST',
            body: formData,
            // Note: Don't set Content-Type header - let browser set it with boundary
        });
        
        updateProgress(50, 'Prosesserer fil...');
        
        const result = await response.json();
        
        updateProgress(90, 'Fullførerer...');
        
        if (response.ok && result.success) {
            currentResult = JSON.parse(result.result);
            showResults(currentResult, file.name, result);
            updateProgress(100, 'Ferdig!');
        } else {
            throw new Error(result.error || `HTTP ${response.status}: ${response.statusText}`);
        }
        
    } catch (error) {
        console.error('Upload failed:', error);
        showError('Feil ved prosessering: ' + error.message);
    } finally {
        setTimeout(() => showProgress(false), 1000);
    }
}

function showProgress(show) {
    const progressSection = document.getElementById('progressSection');
    if (show) {
        progressSection.classList.remove('hidden');
        updateProgress(0, 'Forbereder...');
    } else {
        progressSection.classList.add('hidden');
    }
}

function updateProgress(percent, text) {
    document.getElementById('progressFill').style.width = percent + '%';
    document.getElementById('progressText').textContent = text;
}

function showResults(data, filename, apiResponse) {
    // Show results section
    document.getElementById('resultsSection').classList.remove('hidden');
    
    // Add processing info if available
    if (apiResponse && apiResponse.processingTimeMs) {
        const processingInfo = document.createElement('div');
        processingInfo.className = 'processing-info';
        processingInfo.innerHTML = `
            <p><strong>Prosesseringstid:</strong> ${apiResponse.processingTimeMs}ms</p>
            <p><strong>Filstørrelse:</strong> ${formatFileSize(apiResponse.fileSize || 0)}</p>
        `;
        document.getElementById('resultsSection').insertBefore(processingInfo, document.getElementById('resultsSection').firstChild.nextSibling);
    }
    
    // Show metadata
    showMetadata(data.metadata);
    
    // Show variables
    showVariables(data.variables);
    
    // Show data preview
    showDataPreview(data.data, data.variables);
    
    // Show raw JSON
    showRawJson(data);
    
    // Scroll to results
    document.getElementById('resultsSection').scrollIntoView({ behavior: 'smooth' });
}

function showMetadata(metadata) {
    const content = document.getElementById('metadataContent');
    let html = '<table class="data-table">';
    
    for (const [key, value] of Object.entries(metadata)) {
        html += `<tr><td><strong>${key}:</strong></td><td>${value}</td></tr>`;
    }
    
    html += '</table>';
    content.innerHTML = html;
}

function showVariables(variables) {
    const content = document.getElementById('variablesContent');
    let html = '<table class="data-table"><thead><tr><th>Navn</th><th>Type</th><th>Label</th></tr></thead><tbody>';
    
    variables.forEach(variable => {
        html += `
            <tr>
                <td>${variable.name}</td>
                <td>${variable.type}</td>
                <td>${variable.label || 'N/A'}</td>
            </tr>
        `;
    });
    
    html += '</tbody></table>';
    content.innerHTML = html;
}

function showDataPreview(data, variables) {
    const content = document.getElementById('dataContent');
    let html = '<table class="data-table"><thead><tr>';
    
    // Headers
    variables.forEach(variable => {
        html += `<th>${variable.name}</th>`;
    });
    html += '</tr></thead><tbody>';
    
    // Data rows (max 10)
    const maxRows = Math.min(10, data.length);
    for (let i = 0; i < maxRows; i++) {
        html += '<tr>';
        data[i].forEach(cell => {
            html += `<td>${cell}</td>`;
        });
        html += '</tr>';
    }
    
    html += '</tbody></table>';
    
    if (data.length > 10) {
        html += `<p class="note">Viser første 10 av ${data.length} rader</p>`;
    }
    
    content.innerHTML = html;
}

function showRawJson(data) {
    const content = document.getElementById('rawJsonContent');
    content.textContent = JSON.stringify(data, null, 2);
}

function showError(message) {
    alert('Feil: ' + message);
    showProgress(false);
}

// Download functions
function downloadJson() {
    if (!currentResult) return;
    
    const dataStr = JSON.stringify(currentResult, null, 2);
    const blob = new Blob([dataStr], { type: 'application/json' });
    downloadBlob(blob, 'spss_data.json');
}

function downloadCsv() {
    if (!currentResult || !currentResult.data) return;
    
    let csv = '';
    
    // Headers
    const headers = currentResult.variables.map(v => v.name);
    csv += headers.join(',') + '\n';
    
    // Data
    currentResult.data.forEach(row => {
        csv += row.map(cell => `"${cell}"`).join(',') + '\n';
    });
    
    const blob = new Blob([csv], { type: 'text/csv' });
    downloadBlob(blob, 'spss_data.csv');
}

function downloadBlob(blob, filename) {
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

function copyToClipboard() {
    if (!currentResult) return;
    
    const jsonStr = JSON.stringify(currentResult, null, 2);
    navigator.clipboard.writeText(jsonStr).then(() => {
        alert('JSON kopiert til utklippstavlen!');
    }).catch(err => {
        console.error('Failed to copy to clipboard:', err);
        // Fallback for older browsers
        const textArea = document.createElement('textarea');
        textArea.value = jsonStr;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        alert('JSON kopiert til utklippstavlen!');
    });
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}