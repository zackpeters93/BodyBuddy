// BodyFocus - Main JavaScript
// Task tracking and interactive features

// Task Data Structure (will be loaded from tasks.md dynamically)
let taskData = {
    totalTasks: 73,
    completedTasks: 0,
    phases: []
};

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    updateProgressBars();
    initializeTaskTracking();
});

// Update progress bars across all pages
function updateProgressBars() {
    const progress = calculateOverallProgress();
    const progressBar = document.getElementById('overallProgress');

    if (progressBar) {
        progressBar.style.width = progress + '%';
        progressBar.textContent = Math.round(progress) + '%';
    }
}

// Calculate overall progress
function calculateOverallProgress() {
    if (taskData.totalTasks === 0) return 0;
    return (taskData.completedTasks / taskData.totalTasks) * 100;
}

// Initialize task tracking functionality
function initializeTaskTracking() {
    // Load task data from localStorage if available
    const savedData = localStorage.getItem('bodyfocus_tasks');
    if (savedData) {
        taskData = JSON.parse(savedData);
        updateProgressBars();
    }
}

// Toggle task completion
function toggleTask(taskId) {
    const taskElement = document.getElementById(taskId);
    if (!taskElement) return;

    const isCompleted = taskElement.classList.contains('completed');

    if (isCompleted) {
        taskElement.classList.remove('completed');
        taskElement.classList.add('pending');
        taskData.completedTasks--;
    } else {
        taskElement.classList.remove('pending', 'in-progress');
        taskElement.classList.add('completed');
        if (!isCompleted) {
            taskData.completedTasks++;
        }
    }

    // Save to localStorage
    localStorage.setItem('bodyfocus_tasks', JSON.stringify(taskData));
    updateProgressBars();
}

// Set task status
function setTaskStatus(taskId, status) {
    const taskElement = document.getElementById(taskId);
    if (!taskElement) return;

    const wasCompleted = taskElement.classList.contains('completed');

    taskElement.classList.remove('pending', 'in-progress', 'completed');
    taskElement.classList.add(status);

    if (status === 'completed' && !wasCompleted) {
        taskData.completedTasks++;
    } else if (status !== 'completed' && wasCompleted) {
        taskData.completedTasks--;
    }

    localStorage.setItem('bodyfocus_tasks', JSON.stringify(taskData));
    updateProgressBars();
}

// Filter tasks by phase
function filterTasksByPhase(phase) {
    const allTasks = document.querySelectorAll('.task-item');

    allTasks.forEach(task => {
        if (phase === 'all' || task.dataset.phase === phase) {
            task.style.display = 'block';
        } else {
            task.style.display = 'none';
        }
    });
}

// Filter tasks by status
function filterTasksByStatus(status) {
    const allTasks = document.querySelectorAll('.task-item');

    allTasks.forEach(task => {
        if (status === 'all' || task.classList.contains(status)) {
            task.style.display = 'block';
        } else {
            task.style.display = 'none';
        }
    });
}

// Search tasks
function searchTasks(query) {
    const allTasks = document.querySelectorAll('.task-item');
    const lowerQuery = query.toLowerCase();

    allTasks.forEach(task => {
        const text = task.textContent.toLowerCase();
        if (text.includes(lowerQuery)) {
            task.style.display = 'block';
        } else {
            task.style.display = 'none';
        }
    });
}

// Export task data
function exportTaskData() {
    const dataStr = JSON.stringify(taskData, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);

    const link = document.createElement('a');
    link.href = url;
    link.download = 'bodyfocus_tasks_' + new Date().toISOString().split('T')[0] + '.json';
    link.click();
}

// Import task data
function importTaskData(fileInput) {
    const file = fileInput.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function(e) {
        try {
            taskData = JSON.parse(e.target.result);
            localStorage.setItem('bodyfocus_tasks', JSON.stringify(taskData));
            updateProgressBars();
            location.reload();
        } catch (error) {
            alert('Error importing task data: ' + error.message);
        }
    };
    reader.readAsText(file);
}

// Reset all tasks
function resetAllTasks() {
    if (!confirm('Are you sure you want to reset all task progress? This cannot be undone.')) {
        return;
    }

    taskData.completedTasks = 0;
    localStorage.removeItem('bodyfocus_tasks');
    location.reload();
}

// Smooth scroll to section
function scrollToSection(sectionId) {
    const section = document.getElementById(sectionId);
    if (section) {
        section.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

// Copy code to clipboard
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        showToast('Copied to clipboard!');
    }).catch(err => {
        console.error('Failed to copy:', err);
    });
}

// Show toast notification
function showToast(message, type = 'success') {
    const toastContainer = document.getElementById('toastContainer');
    if (!toastContainer) return;

    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type} border-0`;
    toast.setAttribute('role', 'alert');
    toast.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">${message}</div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    `;

    toastContainer.appendChild(toast);
    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();

    toast.addEventListener('hidden.bs.toast', () => {
        toast.remove();
    });
}

// Expand/collapse all sections
function expandAllSections() {
    document.querySelectorAll('.collapse').forEach(el => {
        const collapse = new bootstrap.Collapse(el, { toggle: false });
        collapse.show();
    });
}

function collapseAllSections() {
    document.querySelectorAll('.collapse.show').forEach(el => {
        const collapse = new bootstrap.Collapse(el, { toggle: false });
        collapse.hide();
    });
}

// Print current page
function printPage() {
    window.print();
}

// Initialize tooltips
const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
