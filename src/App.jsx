import React, { useState, useEffect } from 'react';
import { MapPin, Phone, Mail, Star, Check, RefreshCw, ArrowRight } from 'lucide-react';
import fullLogo from './assets/logos/fulllogo.png';
import transparentLogo from './assets/logos/fulllogo_transparent.png';

export default function DynamicEnvision() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    message: ''
  });

  // Hero background slideshow state
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [isTransitioning, setIsTransitioning] = useState(false);

  // Dynamic image imports using Vite's import.meta.glob
  const windowImages = import.meta.glob('./assets/pictures/windows/*.{jpg,jpeg,png}', { eager: true });
  const exteriorImages = import.meta.glob('./assets/pictures/exterior/*.{jpg,jpeg,png}', { eager: true });

  // Get a location that feels authentic and consistent
  const getSmartLocation = (imagePath, category) => {
    const locations = [
      'Denver', 'Aurora', 'Lakewood', 'Boulder', 'Westminster',
      'Highlands Ranch', 'Centennial', 'Thornton', 'Arvada',
      'Broomfield', 'Wheat Ridge', 'Englewood', 'Littleton'
    ];

    let hash = 0;
    const str = imagePath + category;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }

    const locationIndex = Math.abs(hash) % locations.length;
    return locations[locationIndex];
  };

  // Convert the imported images to a usable format
  const processImages = (imageObj, category) => {
    return Object.entries(imageObj).map(([path, module], index) => {
      const fileName = path.split('/').pop().split('.')[0];

      let title;
      if (fileName.match(/^IMG[_-]/)) {
        const number = fileName.split(/[_-]/)[1] || (index + 1).toString().padStart(4, '0');
        title = `${category} Project ${number}`;
      } else {
        title = fileName.replace(/[-_]/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
      }

      return {
        src: module.default,
        title: title,
        category: category,
        location: getSmartLocation(path, category),
        originalPath: path
      };
    });
  };

  // Process all images
  const windowProjects = processImages(windowImages, 'Windows');
  const exteriorProjects = processImages(exteriorImages, 'Exterior');
  const allProjects = [...windowProjects, ...exteriorProjects];

  // Function to randomly select 6 images from all projects
  const getRandomPortfolioItems = () => {
    if (allProjects.length === 0) return [];
    const shuffled = [...allProjects].sort(() => 0.5 - Math.random());
    return shuffled.slice(0, Math.min(6, allProjects.length));
  };

  const [portfolioItems, setPortfolioItems] = useState(() => getRandomPortfolioItems());

  // Get shuffled images for hero background
  const heroBackgroundImages = React.useMemo(() => {
    if (allProjects.length === 0) return [];
    return [...allProjects].sort(() => 0.5 - Math.random()).slice(0, 8);
  }, [allProjects.length]);

  // Ken Burns slideshow effect
  useEffect(() => {
    if (heroBackgroundImages.length === 0) return;

    const interval = setInterval(() => {
      setIsTransitioning(true);
      setTimeout(() => {
        setCurrentImageIndex((prev) => (prev + 1) % heroBackgroundImages.length);
        setIsTransitioning(false);
      }, 1000); // Crossfade duration
    }, 6000); // Time per image

    return () => clearInterval(interval);
  }, [heroBackgroundImages.length]);

  const refreshPortfolio = () => {
    setPortfolioItems(getRandomPortfolioItems());
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
    alert("Thanks for reaching out! We'll be in touch soon.");
    setFormData({ name: '', email: '', phone: '', message: '' });
  };

  // Smooth scroll handler
  const scrollToSection = (sectionId) => {
    const element = document.getElementById(sectionId);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  // Product categories for hero cards
  const productCategories = [
    {
      id: 'windows',
      title: 'Windows',
      description: 'Energy-efficient replacement windows for every style and budget',
      icon: '🪟',
      features: ['Vinyl', 'Wood', 'Composite', 'Fiberglass']
    },
    {
      id: 'doors',
      title: 'Doors',
      description: 'Entry doors that make a statement and stand the test of time',
      icon: '🚪',
      features: ['Entry', 'French', 'Sliding', 'Patio']
    },
    {
      id: 'exterior',
      title: 'Exterior',
      description: 'Complete exterior solutions to transform your home\'s curb appeal',
      icon: '🏠',
      features: ['Siding', 'Trim', 'Repairs', 'Full Renovations']
    }
  ];

  return (
    <div className="w-full bg-white">
      {/* Navigation */}
      <nav className="sticky top-0 z-50 bg-white/95 backdrop-blur shadow-sm border-b border-gray-200">
        <div className="max-w-6xl mx-auto px-6 py-4 flex justify-between items-center">
          <div className="flex items-center gap-3">
            <img src={transparentLogo} alt="Dynamic Envision Solutions" className="h-10 w-auto" />
            <span className="text-lg font-bold text-gray-900 hidden sm:block">Dynamic Envision Solutions</span>
          </div>
          <div className="flex gap-6 lg:gap-8 text-sm font-medium">
            <a href="#services" className="text-gray-700 hover:text-amber-700 transition">Services</a>
            <a href="#portfolio" className="text-gray-700 hover:text-amber-700 transition">Portfolio</a>
            <a href="#about" className="text-gray-700 hover:text-amber-700 transition">About</a>
            <a href="#contact" className="text-gray-700 hover:text-amber-700 transition">Contact</a>
          </div>
        </div>
      </nav>

      {/* Hero Section - Product Forward with Ken Burns Background */}
      <section className="relative bg-gray-900 text-white overflow-hidden">
        {/* Ken Burns Slideshow Background */}
        <div className="absolute inset-0">
          {heroBackgroundImages.length > 0 && heroBackgroundImages.map((image, index) => (
            <div
              key={index}
              className={`absolute inset-0 transition-opacity duration-1000 ${index === currentImageIndex ? 'opacity-100' : 'opacity-0'
                }`}
            >
              <img
                src={image.src}
                alt=""
                className={`w-full h-full object-cover ${index === currentImageIndex ? 'animate-ken-burns' : ''
                  }`}
                style={{
                  transform: index === currentImageIndex ? undefined : 'scale(1)',
                }}
              />
            </div>
          ))}
          {/* Dark overlay for readability */}
          <div className="absolute inset-0 bg-gray-900/75"></div>
          {/* Subtle gradient overlay */}
          <div className="absolute inset-0 bg-gradient-to-b from-gray-900/50 via-transparent to-gray-900/80"></div>
        </div>

        <div className="relative max-w-6xl mx-auto px-6 py-16 lg:py-24">
          {/* Top section: Logo + headline */}
          <div className="text-center mb-12 lg:mb-16">
            {/* Logo with backdrop */}
            <div className="relative inline-block mb-8">
              {/* Frosted glass backdrop behind logo */}
              <div className="absolute inset-0 -m-6 bg-white/10 backdrop-blur-md rounded-2xl"></div>
              {/* Soft glow effect */}
              <div className="absolute inset-0 -m-8 bg-amber-500/10 blur-2xl rounded-full"></div>
              <img
                src={transparentLogo}
                alt="Dynamic Envision Solutions"
                className="relative w-48 sm:w-56 md:w-64 lg:w-72 h-auto opacity-95 drop-shadow-2xl"
              />
            </div>
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold mb-4 leading-tight drop-shadow-lg">
              What Can We Help You With?
            </h1>
            <p className="text-lg text-gray-300 max-w-2xl mx-auto drop-shadow">
              15 years of premium window and door installation across the Denver metro area.
            </p>
          </div>

          {/* Product Category Cards */}
          <div className="grid md:grid-cols-3 gap-6 lg:gap-8">
            {productCategories.map((category) => (
              <button
                key={category.id}
                onClick={() => scrollToSection(category.id)}
                className="group bg-white/5 backdrop-blur border border-white/10 rounded-xl p-6 lg:p-8 text-left hover:bg-white/10 hover:border-amber-500/50 transition-all duration-300 hover:-translate-y-1"
              >
                <div className="text-4xl mb-4">{category.icon}</div>
                <h3 className="text-xl lg:text-2xl font-bold mb-2 group-hover:text-amber-400 transition-colors">
                  {category.title}
                </h3>
                <p className="text-gray-400 text-sm mb-4">
                  {category.description}
                </p>
                <div className="flex flex-wrap gap-2 mb-4">
                  {category.features.map((feature, idx) => (
                    <span
                      key={idx}
                      className="text-xs bg-white/10 px-2 py-1 rounded-full text-gray-300"
                    >
                      {feature}
                    </span>
                  ))}
                </div>
                <div className="flex items-center text-amber-400 text-sm font-medium group-hover:gap-2 transition-all">
                  <span>Learn more</span>
                  <ArrowRight className="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" />
                </div>
              </button>
            ))}
          </div>

          {/* Trust indicators */}
          <div className="mt-12 lg:mt-16 flex flex-wrap justify-center gap-8 lg:gap-12 text-sm text-gray-400">
            <div className="flex items-center gap-2">
              <Check className="w-5 h-5 text-amber-500" />
              <span>Licensed & Insured</span>
            </div>
            <div className="flex items-center gap-2">
              <Check className="w-5 h-5 text-amber-500" />
              <span>Free Estimates</span>
            </div>
            <div className="flex items-center gap-2">
              <Check className="w-5 h-5 text-amber-500" />
              <span>15+ Years Experience</span>
            </div>
            <div className="flex items-center gap-2">
              <Check className="w-5 h-5 text-amber-500" />
              <span>Denver to Pueblo</span>
            </div>
          </div>
        </div>
      </section>

      {/* Services Detail Sections */}
      <section id="services" className="py-20 px-6 bg-white">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">Our Services</h2>
            <div className="w-20 h-1 bg-amber-500 mx-auto"></div>
          </div>

          {/* Windows Section */}
          <div id="windows" className="mb-20 scroll-mt-24">
            <div className="grid lg:grid-cols-2 gap-12 items-center">
              <div>
                <h3 className="text-2xl lg:text-3xl font-bold text-gray-900 mb-4">
                  Premium Window Replacement
                </h3>
                <p className="text-gray-600 mb-6 leading-relaxed">
                  Whether you're looking to improve energy efficiency, update your home's look, or replace aging windows, we offer a complete range of options to fit your needs and budget.
                </p>
                <div className="grid sm:grid-cols-2 gap-4">
                  {[
                    { type: 'Vinyl', desc: 'Affordable & maintenance-free' },
                    { type: 'Wood', desc: 'Classic warmth & beauty' },
                    { type: 'Composite', desc: 'Durable & energy-efficient' },
                    { type: 'Fiberglass', desc: 'Strong & weather-resistant' }
                  ].map((item, idx) => (
                    <div key={idx} className="bg-gray-50 rounded-lg p-4">
                      <h4 className="font-semibold text-gray-900">{item.type}</h4>
                      <p className="text-sm text-gray-600">{item.desc}</p>
                    </div>
                  ))}
                </div>
              </div>
              <div className="bg-gray-100 rounded-xl aspect-video flex items-center justify-center">
                <span className="text-gray-400">Window Project Image</span>
              </div>
            </div>
          </div>

          {/* Doors Section */}
          <div id="doors" className="mb-20 scroll-mt-24">
            <div className="grid lg:grid-cols-2 gap-12 items-center">
              <div className="order-2 lg:order-1 bg-gray-100 rounded-xl aspect-video flex items-center justify-center">
                <span className="text-gray-400">Door Project Image</span>
              </div>
              <div className="order-1 lg:order-2">
                <h3 className="text-2xl lg:text-3xl font-bold text-gray-900 mb-4">
                  Quality Door Installation
                </h3>
                <p className="text-gray-600 mb-6 leading-relaxed">
                  From making a first impression with a stunning entry door to opening up your living space with patio doors, we deliver craftsmanship that lasts.
                </p>
                <div className="grid sm:grid-cols-2 gap-4">
                  {[
                    { type: 'Entry Doors', desc: 'Curb appeal & security' },
                    { type: 'French Doors', desc: 'Elegant & timeless' },
                    { type: 'Sliding Doors', desc: 'Space-saving design' },
                    { type: 'Patio Doors', desc: 'Indoor-outdoor flow' }
                  ].map((item, idx) => (
                    <div key={idx} className="bg-gray-50 rounded-lg p-4">
                      <h4 className="font-semibold text-gray-900">{item.type}</h4>
                      <p className="text-sm text-gray-600">{item.desc}</p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Exterior Section */}
          <div id="exterior" className="scroll-mt-24">
            <div className="grid lg:grid-cols-2 gap-12 items-center">
              <div>
                <h3 className="text-2xl lg:text-3xl font-bold text-gray-900 mb-4">
                  Exterior Solutions
                </h3>
                <p className="text-gray-600 mb-6 leading-relaxed">
                  Complete your home's transformation with our exterior services. We handle everything from siding and trim to full exterior renovations.
                </p>
                <div className="grid sm:grid-cols-2 gap-4">
                  {[
                    { type: 'Siding', desc: 'Protection & style' },
                    { type: 'Trim Work', desc: 'Finishing details' },
                    { type: 'Repairs', desc: 'Restore & refresh' },
                    { type: 'Renovations', desc: 'Complete transformations' }
                  ].map((item, idx) => (
                    <div key={idx} className="bg-gray-50 rounded-lg p-4">
                      <h4 className="font-semibold text-gray-900">{item.type}</h4>
                      <p className="text-sm text-gray-600">{item.desc}</p>
                    </div>
                  ))}
                </div>
              </div>
              <div className="bg-gray-100 rounded-xl aspect-video flex items-center justify-center">
                <span className="text-gray-400">Exterior Project Image</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Partners Section */}
      <section className="py-16 px-6 bg-gray-50 border-y border-gray-200">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-10">
            <h2 className="text-xl font-semibold text-gray-700 mb-2">Our Trusted Partners</h2>
            <p className="text-gray-500 text-sm">We work with industry-leading manufacturers</p>
          </div>
          <div className="flex flex-wrap justify-center items-center gap-8 lg:gap-16">
            {/* Placeholder partner logos */}
            {['Partner 1', 'Partner 2', 'Partner 3', 'Partner 4'].map((partner, idx) => (
              <div
                key={idx}
                className="w-32 h-16 bg-gray-200 rounded-lg flex items-center justify-center text-gray-400 text-sm"
              >
                {partner}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Portfolio Section */}
      <section id="portfolio" className="py-20 px-6 bg-white">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">Recent Projects</h2>
            <div className="w-20 h-1 bg-amber-500 mx-auto mb-4"></div>
            <p className="text-gray-600">A sample of our work across the Denver metro area</p>
          </div>

          {portfolioItems.length > 0 ? (
            <>
              <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
                {portfolioItems.map((project, idx) => (
                  <div
                    key={idx}
                    className="group relative overflow-hidden rounded-xl aspect-[4/3] bg-gray-100"
                  >
                    <img
                      src={project.src}
                      alt={project.title}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                      <div className="absolute bottom-0 left-0 right-0 p-4">
                        <p className="text-white font-semibold">{project.title}</p>
                        <p className="text-gray-300 text-sm flex items-center gap-1">
                          <MapPin className="w-3 h-3" />
                          {project.location}
                        </p>
                      </div>
                    </div>
                    <div className="absolute top-3 left-3">
                      <span className="bg-white/90 text-gray-900 text-xs font-medium px-2 py-1 rounded-full">
                        {project.category}
                      </span>
                    </div>
                  </div>
                ))}
              </div>

              <div className="text-center">
                <button
                  onClick={refreshPortfolio}
                  className="inline-flex items-center gap-2 text-gray-600 hover:text-amber-700 font-medium transition-colors"
                >
                  <RefreshCw className="w-4 h-4" />
                  Show different projects
                </button>
              </div>
            </>
          ) : (
            <div className="text-center py-12 text-gray-500">
              <p>Portfolio images loading...</p>
            </div>
          )}
        </div>
      </section>

      {/* About Section */}
      <section id="about" className="py-20 px-6 bg-gray-50">
        <div className="max-w-6xl mx-auto">
          <div className="grid lg:grid-cols-2 gap-12 lg:gap-16">
            <div className="space-y-6">
              <h2 className="text-3xl lg:text-4xl font-bold text-gray-900">Our Story</h2>
              <div className="w-20 h-1 bg-amber-500"></div>
              <p className="text-gray-600 leading-relaxed text-lg">
                For 15 years, we've been helping homeowners and businesses in the Denver metro area transform their spaces with premium window and door solutions. What started as a passion for quality craftsmanship has grown into a trusted name from Cheyenne to Pueblo.
              </p>
              <p className="text-gray-600 leading-relaxed text-lg">
                We believe that great windows aren't just about aesthetics—they're about energy efficiency, security, and peace of mind. Every project we undertake reflects our commitment to excellence and customer satisfaction.
              </p>
            </div>

            <div className="space-y-6">
              <h3 className="text-2xl font-bold text-gray-900">What Sets Us Apart</h3>
              <div className="space-y-4">
                {[
                  'Expert installation with 15+ years experience',
                  'Premium quality materials and products',
                  'Detailed consultations and custom solutions',
                  'Competitive pricing and transparent quotes',
                  'Professional, respectful service',
                  'Warranty coverage and ongoing support'
                ].map((item, idx) => (
                  <div key={idx} className="flex gap-4 items-start">
                    <div className="w-6 h-6 bg-amber-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                      <Check className="w-4 h-4 text-white" />
                    </div>
                    <p className="text-gray-700">{item}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Reviews Section */}
      <section id="reviews" className="py-20 px-6 bg-white">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">What Our Customers Say</h2>
            <div className="w-20 h-1 bg-amber-500 mx-auto mb-4"></div>
            <p className="text-gray-600">Reviews coming soon as we build our client portfolio</p>
          </div>

          <div className="bg-gray-50 rounded-xl p-10 text-center mb-10 border-2 border-dashed border-gray-300">
            <div className="w-14 h-14 bg-amber-100 rounded-full flex items-center justify-center mx-auto mb-5">
              <Star className="w-7 h-7 text-amber-600" />
            </div>
            <p className="text-gray-700 text-lg mb-3">
              We're currently building our review section. Early clients are always the foundation of trust.
            </p>
            <p className="text-gray-600 font-medium">
              Have we worked with you? We'd love your feedback!
            </p>
          </div>

          <div className="text-center">
            <h3 className="text-lg font-semibold text-gray-900 mb-3">Find us on Google</h3>
            <p className="text-gray-600 mb-5 text-sm">
              Check out our reviews and ratings on Google Maps for verified customer feedback
            </p>
            <a
              href="#"
              className="inline-block bg-gray-900 text-white px-6 py-3 rounded-lg font-medium hover:bg-gray-800 transition"
            >
              View on Google
            </a>
          </div>
        </div>
      </section>

      {/* Contact Section */}
      <section id="contact" className="py-20 px-6 bg-gray-900 text-white">
        <div className="max-w-2xl mx-auto">
          <div className="text-center mb-10">
            <h2 className="text-3xl lg:text-4xl font-bold mb-4">Get Your Free Quote</h2>
            <div className="w-20 h-1 bg-amber-500 mx-auto mb-4"></div>
            <p className="text-gray-400">Let's discuss your window and door needs</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5 mb-10">
            <div>
              <label className="block text-sm font-medium mb-2 text-gray-300">Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-4 py-3 rounded-lg bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-amber-500 transition-all"
                required
              />
            </div>

            <div className="grid md:grid-cols-2 gap-5">
              <div>
                <label className="block text-sm font-medium mb-2 text-gray-300">Email</label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full px-4 py-3 rounded-lg bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-amber-500 transition-all"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2 text-gray-300">Phone</label>
                <input
                  type="tel"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  className="w-full px-4 py-3 rounded-lg bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-amber-500 transition-all"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium mb-2 text-gray-300">Tell us about your project</label>
              <textarea
                value={formData.message}
                onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                rows="4"
                className="w-full px-4 py-3 rounded-lg bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-amber-500 transition-all"
                required
              ></textarea>
            </div>

            <button
              type="submit"
              className="w-full bg-amber-500 hover:bg-amber-600 text-white py-4 rounded-lg font-bold text-lg transition-all duration-300 shadow-lg hover:shadow-xl"
            >
              Request a Quote
            </button>
          </form>

          <div className="border-t border-gray-700 pt-10 grid md:grid-cols-3 gap-6 text-center">
            <div className="space-y-2">
              <div className="w-10 h-10 bg-amber-500 rounded-full flex items-center justify-center mx-auto">
                <Phone className="w-5 h-5 text-white" />
              </div>
              <p className="text-sm text-gray-400">Call for immediate assistance</p>
            </div>
            <div className="space-y-2">
              <div className="w-10 h-10 bg-amber-500 rounded-full flex items-center justify-center mx-auto">
                <MapPin className="w-5 h-5 text-white" />
              </div>
              <p className="text-sm text-gray-400">Denver Metro to Pueblo</p>
            </div>
            <div className="space-y-2">
              <div className="w-10 h-10 bg-amber-500 rounded-full flex items-center justify-center mx-auto">
                <Check className="w-5 h-5 text-white" />
              </div>
              <p className="text-sm text-gray-400">Free consultations available</p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-black text-gray-400 py-8 px-6">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row justify-between items-center gap-4">
          <p className="text-sm">© 2024 Dynamic Envision Solutions. All rights reserved.</p>
          <div className="flex gap-6 text-sm">
            <a href="#" className="hover:text-white transition">Privacy Policy</a>
            <a href="#" className="hover:text-white transition">Terms of Service</a>
          </div>
        </div>
      </footer>
    </div>
  );
}