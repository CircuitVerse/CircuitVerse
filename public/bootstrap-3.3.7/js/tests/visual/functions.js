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

window.body.backgroundImage = 'url(\'https://wallpapercave.com/wp/pWjhOj3.jpg\')';
      
window.buttons[0].onmouseover = function() {
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[0].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'https://gozonewater.com/wp-content/uploads/2019/06/videoblocks-white-and-grey-paper-geometric-squares-motion-background-seamless-looping-video-animation-ultra-hd-4k-3840x2160_hcxncxphz_thumbnail-full01.png\')';
// this.buttons[0].style.backgroundColor = 'springgreen';
};

// this.buttons[0].onmouseout;
window.buttons[0].onmouseout = function() {
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[0].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'https://wallpapercave.com/wp/pWjhOj3.jpg\')';
// this.buttons[0].style.backgroundColor = '';
};

// this.buttons[1].onmouseover;
window.buttons[1].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[1].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'https://desktopwallpaper.live/wp-content/uploads/2019/06/paper-texture-wallpapers-1.jpg\')';
};

// this.buttons[1].onmouseout;
window.buttons[1].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[1].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'https://wallpapercave.com/wp/pWjhOj3.jpg\')';
};

// this.button[2].onmouseover;
window.buttons[2].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[2].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'https://elizabethporterdesigns.com/image/270013-full_pin-on-my-wallpaper.jpg\')';
};

// this.buttons[2].onmouseout;
window.buttons[2].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[2].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'https://wallpapercave.com/wp/pWjhOj3.jpg\')';
};

// this.buttons[3].onmouseover;
window.buttons[3].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'http://www.4usky.com/data/out/102/164924531-white-wallpapers.jpg\')';
};

// this.buttons[3].onmouseout;
window.buttons[3].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'https://wallpapercave.com/wp/pWjhOj3.jpg\')'; 
}; 
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
window.body.backgroundImage = 'url(\'https://wallpapercave.com/wp/pWjhOj3.jpg\')';
            
window.buttons[0].onmouseover = function() {
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[0].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'https://gozonewater.com/wp-content/uploads/2019/06/videoblocks-white-and-grey-paper-geometric-squares-motion-background-seamless-looping-video-animation-ultra-hd-4k-3840x2160_hcxncxphz_thumbnail-full01.png\')';
// this.buttons[0].style.backgroundColor = 'springgreen';
};

// this.buttons[0].onmouseout;
window.buttons[0].onmouseout = function() {
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[0].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'https://wallpapercave.com/wp/pWjhOj3.jpg\')';
// this.buttons[0].style.backgroundColor = '';
};

// this.buttons[1].onmouseover;
window.buttons[1].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[1].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'https://desktopwallpaper.live/wp-content/uploads/2019/06/paper-texture-wallpapers-1.jpg\')';
};

// this.buttons[1].onmouseout;
window.buttons[1].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[1].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'https://wallpapercave.com/wp/pWjhOj3.jpg\')';
};

// this.button[2].onmouseover;
window.buttons[2].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[3].style.opacity = '0.2';
window.buttons[2].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'https://elizabethporterdesigns.com/image/270013-full_pin-on-my-wallpaper.jpg\')';
};

// this.buttons[2].onmouseout;
window.buttons[2].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[3].style.opacity = '';
window.buttons[2].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'https://wallpapercave.com/wp/pWjhOj3.jpg\')';
};

// this.buttons[3].onmouseover;
window.buttons[3].onmouseover = function() {
window.buttons[0].style.opacity = '0.2';
window.buttons[1].style.opacity = '0.2';
window.buttons[2].style.opacity = '0.2';
window.buttons[3].style.backgroundColor = 'springgreen';
window.body.backgroundImage = 'url(\'http://www.4usky.com/data/out/102/164924531-white-wallpapers.jpg\')';
};

// this.buttons[3].onmouseout;
window.buttons[3].onmouseout = function() {
window.buttons[0].style.opacity = '';
window.buttons[1].style.opacity = '';
window.buttons[2].style.opacity = '';
window.buttons[3].style.backgroundColor = '';
window.body.backgroundImage = 'url(\'https://wallpapercave.com/wp/pWjhOj3.jpg\')'; 
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