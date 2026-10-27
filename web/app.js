fetch('resumes.json')
  .then(response => response.json())
  .then(data => {
    const container = document.getElementById('resumes-container');
    
    for (const [user, resumes] of Object.entries(data)) {
      const card = document.createElement('div');
      card.className = 'user-card';
      
      const title = document.createElement('h2');
      title.textContent = user;
      card.appendChild(title);
      
      const btnGroup = document.createElement('div');
      btnGroup.className = 'btn-group';
      
      resumes.forEach(pdfName => {
        const a = document.createElement('a');
        a.href = `./${user}/${pdfName}.pdf`;
        a.className = 'btn';
        a.textContent = `📄 ${pdfName}`;
        btnGroup.appendChild(a);
      });
      
      card.appendChild(btnGroup);
      container.appendChild(card);
    }
  })
  .catch(error => console.error('Error loading resumes:', error));