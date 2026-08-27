const afk = document.getElementById('afk');
const codeEl = document.getElementById('code');
const input = document.getElementById('input');
const errorEl = document.getElementById('error');
const timeEl = document.getElementById('time');

let timer = null;
let timeLeft = 0;

function resource() {
  return typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'antiafk';
}

function setLocale(locale) {
  if (!locale) return;
  document.getElementById('title').textContent = locale.title;
  document.getElementById('subtitle').textContent = locale.subtitle;
  document.getElementById('timerLabel').textContent = locale.timeLeftLabel;
  document.getElementById('warning').textContent = locale.kickWarning;
  input.placeholder = locale.inputPlaceholder;
  errorEl.dataset.wrongText = locale.wrongCode;
}

function open(data) {
  setLocale(data.locale);
  codeEl.textContent = data.phrase;
  timeLeft = data.time;

  errorEl.textContent = '';
  input.value = '';
  timeEl.textContent = `${timeLeft}s`;

  afk.classList.add('open');
  input.focus();

  clearInterval(timer);
  timer = setInterval(() => {
    timeLeft--;
    timeEl.textContent = `${Math.max(timeLeft, 0)}s`;
    if (timeLeft <= 0) clearInterval(timer);
  }, 1000);
}

function close() {
  afk.classList.remove('open');
  clearInterval(timer);
}

function reject() {
  errorEl.textContent = errorEl.dataset.wrongText || 'Błędny kod!';
  codeEl.classList.remove('shake');
  codeEl.offsetWidth; // restart animacji
  codeEl.classList.add('shake');
  input.value = '';
  input.focus();
}

function submit() {
  const answer = input.value.trim();
  if (!answer) return;

  fetch(`https://${resource()}/submit`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ answer })
  }).catch(() => {});
}

window.addEventListener('message', (e) => {
  const { action, ...data } = e.data || {};
  if (action === 'show') open(data);
  if (action === 'hide') close();
  if (action === 'wrong') reject();
});

input.addEventListener('keydown', (e) => {
  if (e.key === 'Enter') submit();
});
