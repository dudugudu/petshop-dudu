// Apresentação Pet Shop: navegação, escala 16:9, pontos do código, tela cheia e notas.
//
// Teclas:
//   → / PageDown / Espaço   próximo passo (ou próximo slide)
//   ← / PageUp              passo anterior (ou slide anterior)
//   Home / End              primeiro / último slide
//   F                       tela cheia
//   N                       notas do apresentador
//
// Adicionar ?slide=8 à URL abre direto no slide 8.
// Adicionar ?verificar mede se algum conteúdo sai da área útil de cada slide.
// Adicionar ?limpo mostra o slide em tamanho cheio, sem os controles (para capturas).

(function () {
  'use strict';

  var LARGURA = 1920;
  var ALTURA = 1080;
  var BASE_CONTEUDO = 920;   // o conteúdo precisa terminar antes do rodapé
  var DIREITA_CONTEUDO = 1792; // margem direita de 128 px
  var limpo = /[?&]limpo/.test(location.search); // só o slide, em tamanho cheio (capturas)

  var slides = Array.prototype.slice.call(document.querySelectorAll('.slide'));
  var total = slides.length;
  var palco = document.querySelector('[data-palco]');
  var contador = document.querySelector('[data-contador]');
  var progresso = document.querySelector('[data-progresso] span');
  var btnAnterior = document.querySelector('[data-anterior]');
  var btnProximo = document.querySelector('[data-proximo]');
  var btnTela = document.querySelector('[data-tela]');
  var btnNotas = document.querySelector('[data-notas-botao]');
  var painelNotas = document.querySelector('[data-notas]');

  var atual = 0;
  var passo = 1;

  function passosDo(slide) {
    return slide.querySelectorAll('.passo').length;
  }

  // Mostra o ponto de código de número p e destaca as linhas dele
  function mostrarPasso(slide, p) {
    var passos = slide.querySelectorAll('.passo');
    Array.prototype.forEach.call(passos, function (el, i) {
      el.hidden = i !== p - 1;
    });
    var indicador = slide.querySelector('[data-passo-contador]');
    if (indicador) indicador.textContent = p + ' / ' + passos.length;

    var alvo = passos[p - 1];
    var ini = alvo ? +alvo.getAttribute('data-ini') : 0;
    var fim = alvo ? +alvo.getAttribute('data-fim') : 0;
    Array.prototype.forEach.call(slide.querySelectorAll('.ln'), function (linha) {
      var n = +linha.getAttribute('data-n');
      linha.classList.toggle('hl', n >= ini && n <= fim);
    });
  }

  function mostrarNotas() {
    var nota = slides[atual].querySelector('.notas-fala');
    painelNotas.textContent = nota ? nota.textContent : 'Sem notas neste slide.';
  }

  function atualizar() {
    var ultimoPasso = Math.max(1, passosDo(slides[atual]));
    contador.textContent = (atual + 1) + ' / ' + total;
    progresso.style.width = ((atual + 1) / total * 100) + '%';
    btnAnterior.disabled = atual === 0 && passo <= 1;
    btnProximo.disabled = atual === total - 1 && passo >= ultimoPasso;
    if (!painelNotas.hidden) mostrarNotas();
  }

  // Vai ao slide i, no passo p (1 por padrão)
  function ir(i, p) {
    atual = Math.max(0, Math.min(total - 1, i));
    passo = Math.max(1, Math.min(p || 1, Math.max(1, passosDo(slides[atual]))));
    slides.forEach(function (s, k) {
      if (k === atual && s.hidden) {
        s.hidden = false;
        s.classList.remove('entrando');
        void s.offsetWidth; // reinicia a animação de entrada
        s.classList.add('entrando');
      } else {
        s.hidden = k !== atual;
      }
    });
    if (passosDo(slides[atual])) mostrarPasso(slides[atual], passo);
    atualizar();
  }

  function proximo() {
    var n = passosDo(slides[atual]);
    if (n && passo < n) ir(atual, passo + 1);
    else ir(atual + 1, 1);
  }

  function anterior() {
    if (passosDo(slides[atual]) && passo > 1) {
      ir(atual, passo - 1);
    } else if (atual > 0) {
      var n = passosDo(slides[atual - 1]);
      ir(atual - 1, n || 1); // volta ao último passo do slide anterior
    }
  }

  // Escala o palco para caber na janela (com espaço para os controles) ou na tela cheia
  function ajustar() {
    var cheia = !!document.fullscreenElement || limpo;
    var margem = cheia ? 0 : 16;
    var reserva = cheia ? 0 : 88;
    var k = Math.min(
      (window.innerWidth - 2 * margem) / LARGURA,
      (window.innerHeight - reserva - 2 * margem) / ALTURA
    );
    k = Math.max(k, 0.05);
    palco.style.width = (LARGURA * k) + 'px';
    palco.style.height = (ALTURA * k) + 'px';
    document.documentElement.style.setProperty('--k', k);
  }

  function alternarTela() {
    if (document.fullscreenElement) {
      var saida = document.exitFullscreen && document.exitFullscreen();
      if (saida && saida.catch) saida.catch(function () {});
    } else {
      var entrada = document.documentElement.requestFullscreen && document.documentElement.requestFullscreen();
      if (entrada && entrada.catch) entrada.catch(function () {});
    }
  }

  function alternarNotas() {
    painelNotas.hidden = !painelNotas.hidden;
    if (!painelNotas.hidden) mostrarNotas();
  }

  // Mede se algum conteúdo sai da área útil de cada slide, em cada ponto do código
  function verificar() {
    var k = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--k')) || 1;
    var resultado = slides.map(function (s, i) {
      var estavaOculto = s.hidden;
      s.hidden = false;
      var origem = s.getBoundingClientRect();
      var problemas = [];
      var corpo = s.querySelector('.corpo');
      var temPassos = passosDo(s) > 0;
      var total = Math.max(1, passosDo(s));
      for (var p = 1; p <= total && corpo; p++) {
        if (temPassos) mostrarPasso(s, p);
        var rotulo = temPassos ? 'passo ' + p + ' ' : '';
        Array.prototype.forEach.call(corpo.querySelectorAll('*'), function (el) {
          var r = el.getBoundingClientRect();
          if (r.width === 0 && r.height === 0) return;
          var base = (r.bottom - origem.top) / k;
          var direita = (r.right - origem.left) / k;
          var nome = el.getAttribute('class') || el.tagName.toLowerCase();
          if (base > BASE_CONTEUDO + 5) problemas.push(rotulo + 'base ' + Math.round(base) + ' (' + nome + ')');
          if (direita > DIREITA_CONTEUDO + 2) problemas.push(rotulo + 'direita ' + Math.round(direita) + ' (' + nome + ')');
        });
      }
      s.hidden = estavaOculto;
      return (i + 1) + ':' + (problemas.length ? problemas.slice(0, 3).join(' ') : 'ok');
    });
    document.body.setAttribute('data-verificacao', resultado.join(' | '));
    ir(atual, passo);
  }

  // Eventos
  btnAnterior.addEventListener('click', anterior);
  btnProximo.addEventListener('click', proximo);
  btnTela.addEventListener('click', alternarTela);
  btnNotas.addEventListener('click', alternarNotas);

  document.addEventListener('keydown', function (e) {
    var emBotao = e.target && e.target.closest && e.target.closest('button');
    if (e.key === 'ArrowRight' || e.key === 'PageDown' || (e.key === ' ' && !emBotao)) {
      e.preventDefault();
      proximo();
    } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
      e.preventDefault();
      anterior();
    } else if (e.key === 'Home') {
      ir(0, 1);
    } else if (e.key === 'End') {
      ir(total - 1, 1);
    } else if (e.key === 'f' || e.key === 'F') {
      alternarTela();
    } else if (e.key === 'n' || e.key === 'N') {
      alternarNotas();
    }
  });

  // Toque: deslizar para os lados
  var xInicial = null;
  palco.addEventListener('touchstart', function (e) { xInicial = e.touches[0].clientX; }, { passive: true });
  palco.addEventListener('touchend', function (e) {
    if (xInicial === null) return;
    var dx = e.changedTouches[0].clientX - xInicial;
    xInicial = null;
    if (Math.abs(dx) > 50) {
      if (dx < 0) proximo();
      else anterior();
    }
  }, { passive: true });

  document.addEventListener('fullscreenchange', function () {
    document.documentElement.classList.toggle('tela-cheia', !!document.fullscreenElement);
    ajustar();
  });
  window.addEventListener('resize', ajustar);

  if (limpo) document.documentElement.classList.add('tela-cheia');
  ajustar();
  var pedido = /[?&]slide=(\d+)/.exec(location.search);
  ir(pedido ? +pedido[1] - 1 : 0, 1);
  if (/[?&]verificar/.test(location.search)) verificar();
})();
