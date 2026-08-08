export const SUPABASE_URL = "https://gwcfjvbpgwmzmvvhahhl.supabase.co";
export const SUPABASE_ANON_KEY = "sb_publishable_Vzj9LwwhB32XxluzA2XhZg_1lHjCTy9";
export const ADMIN_EMAIL = "vkvishalk67@gmail.com";

export function logoSVG(size=34, dark=true){
  const ring = dark ? '#B8863B' : '#1B2333';
  const thread = dark ? '#D4A75C' : '#1B2333';
  const bg = dark ? '#1B2333' : 'none';
  return `<svg width="${size}" height="${size}" viewBox="0 0 34 34" fill="none" xmlns="http://www.w3.org/2000/svg">
    ${bg !== 'none' ? `<circle cx="17" cy="17" r="16" fill="${bg}"/>` : ''}
    <circle cx="17" cy="17" r="10" fill="none" stroke="${ring}" stroke-width="2"/>
    <path d="M9 17 Q17 9 25 17 Q17 25 9 17" stroke="${thread}" stroke-width="1.5" fill="none"/>
    <circle cx="17" cy="17" r="2.5" fill="${ring}"/>
  </svg>`;
}

export function escapeHtml(str){
  const d = document.createElement('div');
  d.textContent = str ?? '';
  return d.innerHTML;
}

export function formatDate(d){
  if (!d) return '—';
  const dt = new Date(d);
  return dt.toLocaleDateString('en-GB', { day:'2-digit', month:'short', year:'numeric' });
}

export function isValidCnic(cnic){
  const digits = (cnic || '').replace(/[^0-9]/g, '');
  return digits.length === 13;
}

export function normalizeCnic(cnic){
  return (cnic || '').replace(/[^0-9]/g, '');
}

export function waLink(phone, message){
  const digits = (phone || '').replace(/[^0-9]/g, '');
  const num = digits.startsWith('92') ? digits : ('92' + digits.replace(/^0/, ''));
  return `https://wa.me/${num}?text=${encodeURIComponent(message)}`;
}

const CAUTION_AREAS = ['balochistan','quetta','turbat','khuzdar','kech','panjgur','waziristan','kurram'];
export function isCautionArea(areaText){
  const a = (areaText || '').toLowerCase();
  return CAUTION_AREAS.some(k => a.includes(k));
}

export async function checkCnicBlocked(supabase, cnic){
  const normalized = normalizeCnic(cnic);
  const { data } = await supabase.from('blocked_cnics').select('cnic').eq('cnic', normalized).maybeSingle();
  return !!data;
}
