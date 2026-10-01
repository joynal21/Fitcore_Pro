document.addEventListener('DOMContentLoaded',()=>{
 const sidebar=document.getElementById('sidebar'); const toggle=document.getElementById('menuToggle');
 if(toggle) toggle.addEventListener('click',()=>sidebar?.classList.toggle('open'));
 document.addEventListener('click',e=>{if(window.innerWidth<992&&sidebar?.classList.contains('open')&&!sidebar.contains(e.target)&&e.target!==toggle)sidebar.classList.remove('open')});
 document.querySelectorAll('[data-confirm]').forEach(el=>el.addEventListener('click',e=>{if(!confirm(el.dataset.confirm||'Are you sure?'))e.preventDefault()}));
 document.querySelectorAll('[data-count]').forEach(el=>{const target=Number(el.dataset.count||0), duration=700, start=performance.now(); const step=t=>{const p=Math.min((t-start)/duration,1); el.textContent=Math.round(target*(1-Math.pow(1-p,3))).toLocaleString(); if(p<1)requestAnimationFrame(step)}; requestAnimationFrame(step)});
});
