var buttons, i, body;

// this.buttons[0].onmouseover;
buttons = window.document.getElementsByTagName('button');
body = window.document.body.style; 

for(i = 0; i < buttons.length; i++) {
  window.buttons[i].style.transitionDelay = '0s';
  window.buttons[i].style.transitionProperty = 'all';
  window.buttons[i].style.transitionDuration = '0.9s';
  window.buttons[i].style.trasitionTimingFunction = 'ease';
  window.buttons[i].style.outlineWidth = '0px';
  window.buttons[i].style.fontWeight = 'bold';
  window.buttons[i].style.cursor = 'grab';
}
    
window.body.transitionDelay = '0s';
window.body.transitionDuration = '1s';
window.body.transitionProperty = 'all';
window.body.trasitionTimingFunction = 'ease';
window.body.backgroundPositionX = 'center';
window.body.backgroundPositionY = 'center';
window.body.backgroundAttachment = 'fixed';
window.body.backgroundRepeatX = 'no-repeat';
window.body.backgroundRepeatY = 'no-repeat';
window.body.backgroundSize = '100% 100%';
window.body.backgroundAttachment = 'fixed';
  
  if(window.outerWidth > 1250 && window.outerHeight > 960) { 

window.body.backgroundImage = 'url(\'plainWhite.jpg\')';
      
window.buttons[0].onmouseover = function() {
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[0].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'background0.png\')';
// this.buttons[0].style.backgroundColor = 'springgreen';
};

// this.buttons[0].onmouseout;
window.buttons[0].onmouseout = function() {
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[0].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'plainWhite.jpg\')';
// this.buttons[0].style.backgroundColor = '';
};

// this.buttons[1].onmouseover;
window.buttons[1].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[1].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'paper1.jpg\')'
};

// this.buttons[1].onmouseout;
window.buttons[1].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[1].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'plainWhite.jpg\')';
};

// this.button[2].onmouseover;
window.buttons[2].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[2].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'background2.jpg\')';
};

// this.buttons[2].onmouseout;
window.buttons[2].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[2].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'plainWhite.jpg\')';
};

// this.buttons[3].onmouseover;
window.buttons[3].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'background03.jpg\')';
};

// this.buttons[3].onmouseout;
window.buttons[3].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'plainWhite.jpg\')'; 
}; ; 
}
  else { 
// window.body.backgroundImage = '';
window.buttons[0].onmouseover = function() {
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[0].style.backgroundColor = 'springgreen';
// window.body.backgroundImage = 'url(\'background0.png\')';
// this.buttons[0].style.backgroundColor = 'springgreen';
};

// this.buttons[0].onmouseout;
window.buttons[0].onmouseout = function() {
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[0].style.backgroundColor = '';
// window.body.backgroundImage = '';
// this.buttons[0].style.backgroundColor = '';
};

// this.buttons[1].onmouseover;
window.buttons[1].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[1].style.backgroundColor = 'springgreen';
// window.body.backgroundImage = 'url(\'background1.png\')'
};

// this.buttons[1].onmouseout;
window.buttons[1].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[1].style.backgroundColor = '';
// window.body.backgroundImage = '';
};

// this.button[2].onmouseover;
window.buttons[2].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[2].style.backgroundColor = 'springgreen';
// window.body.backgroundImage = 'url(\'background2.jpg\')';
};

// this.buttons[2].onmouseout;
window.buttons[2].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[2].style.backgroundColor = '';
// window.body.backgroundImage = '';
};

// this.buttons[3].onmouseover;
window.buttons[3].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.backgroundColor = 'springgreen';
// window.body.backgroundImage = 'url(\'background3.jpg\')';
};

// this.buttons[3].onmouseout;
window.buttons[3].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.backgroundColor = '';
// window.body.backgroundImage = ''; 
};      
  }

    
    
    window.document.body.onresize = function() {
        
        if(window.outerWidth > 1250 && window.outerHeight > 960) {
window.body.backgroundImage = 'url(\'plainWhite.jpg\')';
            
window.buttons[0].onmouseover = function() {
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[0].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'background0.png\')';
// this.buttons[0].style.backgroundColor = 'springgreen';
};

// this.buttons[0].onmouseout;
window.buttons[0].onmouseout = function() {
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[0].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'plainWhite.jpg\')';
// this.buttons[0].style.backgroundColor = '';
};

// this.buttons[1].onmouseover;
window.buttons[1].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[1].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'paper1.jpg\')'
};

// this.buttons[1].onmouseout;
window.buttons[1].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[1].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'plainWhite.jpg\')';
};

// this.button[2].onmouseover;
window.buttons[2].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[2].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'background2.jpg\')';
};

// this.buttons[2].onmouseout;
window.buttons[2].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[2].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'plainWhite.jpg\')';
};

// this.buttons[3].onmouseover;
window.buttons[3].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'background03.jpg\')';
};

// this.buttons[3].onmouseout;
window.buttons[3].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'plainWhite.jpg\')'; 
};  
        }
        else {
window.body.backgroundImage = '';
            
window.buttons[0].onmouseover = function() {
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[0].style.backgroundColor = 'springgreen';
// window.body.backgroundImage = 'url(\'background0.png\')';
// this.buttons[0].style.backgroundColor = 'springgreen';
};

// this.buttons[0].onmouseout;
window.buttons[0].onmouseout = function() {
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[0].style.backgroundColor = '';
// window.body.backgroundImage = '';
// this.buttons[0].style.backgroundColor = '';
};

// this.buttons[1].onmouseover;
window.buttons[1].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[1].style.backgroundColor = 'springgreen';
// window.body.backgroundImage = 'url(\'background1.png\')'
};

// this.buttons[1].onmouseout;
window.buttons[1].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[1].style.backgroundColor = '';
// window.body.backgroundImage = '';
};

// this.button[2].onmouseover;
window.buttons[2].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[2].style.backgroundColor = 'springgreen';
// window.body.backgroundImage = 'url(\'background2.jpg\')';
};

// this.buttons[2].onmouseout;
window.buttons[2].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[2].style.backgroundColor = '';
// window.body.backgroundImage = '';
};

// this.buttons[3].onmouseover;
window.buttons[3].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.backgroundColor = 'springgreen';
// window.body.backgroundImage = 'url(\'background3.jpg\')';
};

// this.buttons[3].onmouseout;
window.buttons[3].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.backgroundColor = '';
// window.body.backgroundImage = ''; 
};   
        }
    };