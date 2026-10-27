// Словари для красивого отображения
const LANG_MAP = {
    'ru': { flag: '🇷🇺', name: 'Русский' },
    'en': { flag: '🇬🇧', name: 'English' },
    'de': { flag: '🇩🇪', name: 'Deutsch' },
    'fr': { flag: '🇫🇷', name: 'Français' }
};

const TEMPLATE_MAP = {
    'google-classic': 'Classic Template',
    'modern': 'Modern Template'
};

document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('resumes-container');
    const loading = document.getElementById('loading');
    const errorMsg = document.getElementById('error-message');

    fetch('resumes.json')
        .then(response => {
            if (!response.ok) throw new Error('File not found');
            return response.json();
        })
        .then(data => {
            loading.style.display = 'none';
            
            // Проходимся по пользователям
            for (const [user, files] of Object.entries(data)) {
                const card = document.createElement('div');
                card.className = 'user-card';
                
                // Красивое имя пользователя (например, v.s.buchnev -> V.S. Buchnev)
                const displayName = user.split('.').map(part => 
                    part.charAt(0).toUpperCase() + part.slice(1)
                ).join('. ');

                const title = document.createElement('h2');
                title.textContent = displayName;
                card.appendChild(title);
                
                const btnGroup = document.createElement('div');
                btnGroup.className = 'btn-group';
                
                files.forEach(pdfName => {
                    // pdfName приходит как "resume_google-classic_ru"
                    // Отрезаем "resume_" и разбиваем по "_"
                    const cleanName = pdfName.replace('resume_', '');
                    const parts = cleanName.split('_');
                    const templateKey = parts[0];
                    const langKey = parts[1];

                    const langInfo = LANG_MAP[langKey] || { flag: '📄', name: langKey.toUpperCase() };
                    const templateName = TEMPLATE_MAP[templateKey] || templateKey;

                    const a = document.createElement('a');
                    a.href = `./${user}/${pdfName}.pdf`;
                    a.className = 'btn';
                    a.target = '_blank'; // Открывать PDF в новой вкладке
                    
                    a.innerHTML = `
                        <span class="flag">${langInfo.flag}</span>
                        <span class="btn-text">
                            <strong>${langInfo.name}</strong>
                            <small>${templateName}</small>
                        </span>
                    `;
                    btnGroup.appendChild(a);
                });
                
                card.appendChild(btnGroup);
                container.appendChild(card);
            }
        })
        .catch(error => {
            console.error('Error:', error);
            loading.style.display = 'none';
            errorMsg.style.display = 'block';
        });
});