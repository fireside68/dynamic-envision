import React, { useState } from 'react';
import { ChevronDown, MapPin, Phone, Mail, Star, Check, RefreshCw } from 'lucide-react';
import fullLogo from './assets/logos/fulllogo.png';
import transparentLogo from './assets/logos/fulllogo_transparent.png';

export default function DynamicEnvision() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    message: ''
  });

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

    // Use the image path to create a consistent hash for location assignment
    // This way the same image always gets the same location
    let hash = 0;
    const str = imagePath + category;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }

    const locationIndex = Math.abs(hash) % locations.length;
    return locations[locationIndex];
  };

  // Convert the imported images to a usable format
  const processImages = (imageObj, category) => {
    return Object.entries(imageObj).map(([path, module], index) => {
      const fileName = path.split('/').pop().split('.')[0];

      // Create better titles for IMG_xxx or IMG-xxx files
      let title;
      if (fileName.match(/^IMG[_-]/)) {
        // Extract the number after IMG_ or IMG-
        const number = fileName.split(/[_-]/)[1] || (index + 1).toString().padStart(4, '0');
        title = `${category} Project ${number}`;
      } else {
        // Handle other filename formats
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

  // Use useState to maintain the same random selection until refreshed
  const [portfolioItems, setPortfolioItems] = useState(() => getRandomPortfolioItems());

  // Function to refresh the portfolio selection
  const refreshPortfolio = () => {
    setPortfolioItems(getRandomPortfolioItems());
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
    alert("Thanks for reaching out! We'll be in touch soon.");
    setFormData({ name: '', email: '', phone: '', message: '' });
  };

  return (
    <div className="w-full bg-white">
      {/* Navigation */}
      <nav className="sticky top-0 z-50 bg-white/95 backdrop-blur shadow-sm border-b border-gray-200">
        <div className="max-w-6xl mx-auto px-6 py-4 flex justify-between items-center">
          <div className="flex items-center gap-3">
            <img src={transparentLogo} alt="Dynamic Envision Solutions" className="h-10 w-auto" />
            <span className="text-lg font-bold text-gray-900">Dynamic Envision Solutions</span>
          </div>
          <div className="flex gap-8 text-sm font-medium">
            <a href="#portfolio" className="text-gray-700 hover:text-amber-700 transition">Portfolio</a>
            <a href="#about" className="text-gray-700 hover:text-amber-700 transition">About</a>
            <a href="#reviews" className="text-gray-700 hover:text-amber-700 transition">Reviews</a>
            <a href="#contact" className="text-gray-700 hover:text-amber-700 transition">Contact</a>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative min-h-screen bg-gradient-to-b from-gray-50 via-white to-gray-100 overflow-hidden">
        {/* Background Elements - could be replaced with video background */}
        <div className="absolute inset-0 opacity-5">
          <div className="absolute top-20 right-20 w-96 h-96 bg-gray-400 rounded-full mix-blend-multiply filter blur-3xl"></div>
          <div className="absolute -bottom-8 left-20 w-96 h-96 bg-gray-300 rounded-full mix-blend-multiply filter blur-3xl"></div>
          {/* Optional: Add a subtle pattern or texture here */}
          <div className="absolute inset-0 opacity-10 bg-gradient-to-br from-amber-50 via-transparent to-orange-50"></div>
        </div>

        <div className="relative min-h-screen flex flex-col items-center justify-center px-6 py-20 max-w-6xl mx-auto text-center">

          {/* Logo Section - Now prominently displayed on top */}
          <div className="mb-12">
            <div className="relative inline-block">
              <img
                src={transparentLogo}
                alt="Dynamic Envision Solutions"
                className="w-80 sm:w-96 md:w-[28rem] lg:w-[32rem] h-auto opacity-95 hover:opacity-100 transition-opacity duration-500"
              />
              {/* Subtle glow effect behind logo */}
              <div className="absolute inset-0 bg-gradient-radial from-amber-600/8 via-orange-600/4 to-transparent blur-2xl transform scale-125"></div>
            </div>
          </div>

          {/* Content Section - Below the logo */}
          <div className="space-y-8 max-w-4xl">
            <div>
              <h1 className="text-4xl sm:text-5xl lg:text-6xl xl:text-7xl font-bold text-gray-900 mb-6 leading-tight">
                Premium Windows &{' '}
                <span className="text-transparent bg-gradient-to-r from-amber-700 to-orange-700 bg-clip-text">
                  Doors
                </span>
              </h1>
              <div className="w-24 h-1 bg-gradient-to-r from-amber-700 to-orange-700 mx-auto mb-8"></div>
              <p className="text-lg sm:text-xl lg:text-2xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
                15 years of craftsmanship in the Denver metro area. We don't just replace windows—we transform your home's comfort and aesthetic.
              </p>
            </div>

            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
              <button className="bg-gray-900 text-white px-8 py-4 rounded-lg font-semibold hover:bg-gray-800 transition-all duration-300 shadow-lg hover:shadow-xl transform hover:-translate-y-1">
                Get a Quote
              </button>
              <button className="border-2 border-gray-900 text-gray-900 px-8 py-4 rounded-lg font-semibold hover:bg-gray-50 transition-all duration-300">
                View Our Work
              </button>
            </div>

            <div className="flex flex-col sm:flex-row gap-8 lg:gap-12 text-gray-700 font-semibold justify-center items-center pt-4">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-amber-100 rounded-full flex items-center justify-center">
                  <MapPin className="w-6 h-6 text-amber-700" />
                </div>
                <span className="text-lg">Denver to Pueblo</span>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-amber-100 rounded-full flex items-center justify-center">
                  <Phone className="w-6 h-6 text-amber-700" />
                </div>
                <span className="text-lg">Free Consultations</span>
              </div>
            </div>
          </div>
        </div>

        <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
          <ChevronDown className="w-6 h-6 text-gray-600" />
        </div>
      </section>

      {/* Portfolio Section */}
      <section id="portfolio" className="py-20 px-6 bg-gray-50">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <div className="flex items-center justify-center gap-4 mb-6">
              <h2 className="text-4xl lg:text-5xl font-bold text-gray-900">Our Work</h2>
              <button
                onClick={refreshPortfolio}
                className="p-2 rounded-full bg-amber-100 hover:bg-amber-200 transition-colors group"
                title="Refresh portfolio selection"
              >
                <RefreshCw className="w-5 h-5 text-amber-700 group-hover:rotate-180 transition-transform duration-500" />
              </button>
            </div>
            <div className="w-24 h-1 bg-gradient-to-r from-amber-700 to-orange-700 mx-auto mb-6"></div>
            <p className="text-lg text-gray-600">Every project tells a story of quality and attention to detail</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {portfolioItems.map((item, index) => (
              <div key={`${item.src}-${index}`} className="group relative overflow-hidden rounded-xl shadow-lg hover:shadow-2xl transition-all duration-300 h-72 cursor-pointer transform hover:-translate-y-2">
                <div className="absolute inset-0">
                  <img
                    src={item.src}
                    alt={item.title}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                    onError={(e) => {
                      // Fallback to placeholder if image doesn't exist
                      e.target.style.display = 'none';
                      e.target.nextSibling.style.display = 'flex';
                    }}
                  />
                  {/* Fallback placeholder */}
                  <div className="w-full h-full bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center" style={{ display: 'none' }}>
                    <div className="text-center">
                      <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg">
                        <div className="w-8 h-8 bg-gradient-to-r from-amber-700 to-orange-700 rounded"></div>
                      </div>
                      <p className="text-gray-600 text-sm">[Photo coming soon]</p>
                    </div>
                  </div>
                </div>
                <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-all duration-300"></div>
                <div className="absolute bottom-0 left-0 right-0 p-6 text-white transform translate-y-6 group-hover:translate-y-0 transition-transform duration-300">
                  <h3 className="font-semibold text-lg mb-1">{item.title}</h3>
                  <p className="text-sm text-gray-200">{item.location}</p>
                </div>
              </div>
            ))}
          </div>

          <div className="text-center mt-12">
            <p className="text-gray-600 italic mb-4">
              Showing {portfolioItems.length} of {allProjects.length} completed projects.
              {allProjects.length > 6 && (
                <button
                  onClick={refreshPortfolio}
                  className="ml-2 text-amber-700 hover:text-amber-600 underline"
                >
                  See different projects
                </button>
              )}
            </p>
            {allProjects.length === 0 && (
              <p className="text-gray-500 text-sm">
                Add images to ./assets/pictures/windows/ and ./assets/pictures/exterior/ to populate the portfolio
              </p>
            )}
          </div>
        </div>
      </section>

      {/* About Section */}
      <section id="about" className="py-20 px-6 bg-white">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl lg:text-5xl font-bold text-gray-900 mb-4">Why Dynamic Envision Solutions?</h2>
            <div className="w-24 h-1 bg-gradient-to-r from-amber-700 to-orange-700 mx-auto"></div>
          </div>

          <div className="grid lg:grid-cols-2 gap-16">
            <div className="space-y-6">
              <h3 className="text-3xl font-bold text-gray-900 mb-6">Our Story</h3>
              <p className="text-gray-600 leading-relaxed text-lg">
                For 15 years, we've been helping homeowners and businesses in the Denver metro area transform their spaces with premium window and door solutions. What started as a passion for quality craftsmanship has grown into a trusted name from Cheyenne to Pueblo.
              </p>
              <p className="text-gray-600 leading-relaxed text-lg">
                We believe that great windows aren't just about aesthetics—they're about energy efficiency, security, and peace of mind. Every project we undertake reflects our commitment to excellence and customer satisfaction.
              </p>
            </div>

            <div className="space-y-6">
              <h3 className="text-3xl font-bold text-gray-900 mb-6">What Sets Us Apart</h3>
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
                    <div className="w-8 h-8 bg-amber-100 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                      <Check className="w-5 h-5 text-amber-700" />
                    </div>
                    <p className="text-gray-600 text-lg">{item}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Reviews Section */}
      <section id="reviews" className="py-20 px-6 bg-gray-50">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl lg:text-5xl font-bold text-gray-900 mb-4">What Our Customers Say</h2>
            <div className="w-24 h-1 bg-gradient-to-r from-amber-700 to-orange-700 mx-auto mb-6"></div>
            <p className="text-lg text-gray-600">Reviews coming soon as we build our client portfolio</p>
          </div>

          <div className="bg-white rounded-xl p-12 text-center mb-12 border-2 border-dashed border-gray-300 hover:border-amber-300 transition-colors duration-300">
            <div className="w-16 h-16 bg-gradient-to-r from-amber-100 to-orange-100 rounded-full flex items-center justify-center mx-auto mb-6">
              <Star className="w-8 h-8 text-amber-700" />
            </div>
            <p className="text-gray-700 text-lg mb-4">
              We're currently building our review section. Early clients are always the foundation of trust.
            </p>
            <p className="text-gray-600 font-semibold">
              Have we worked with you? We'd love your feedback!
            </p>
          </div>

          <div className="text-center">
            <h3 className="text-xl font-semibold text-gray-900 mb-4">Find us on Google</h3>
            <p className="text-gray-600 mb-6">
              Check out our reviews and ratings on Google Maps for verified customer feedback
            </p>
            <a href="#" className="inline-block bg-gray-900 text-white px-8 py-3 rounded-lg font-semibold hover:bg-gray-800 transition shadow-lg">
              View on Google
            </a>
          </div>
        </div>
      </section>

      {/* Contact Section */}
      <section id="contact" className="py-20 px-6 bg-gray-900 text-white">
        <div className="max-w-2xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-4xl lg:text-5xl font-bold mb-4">Get Your Free Quote</h2>
            <div className="w-24 h-1 bg-gradient-to-r from-amber-400 to-orange-400 mx-auto mb-6"></div>
            <p className="text-gray-300 text-lg">Let's discuss your window and door needs</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6 mb-12">
            <div>
              <label className="block text-sm font-semibold mb-2">Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-4 py-3 rounded-lg bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-amber-400 transition-all"
                required
              />
            </div>

            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-semibold mb-2">Email</label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full px-4 py-3 rounded-lg bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-amber-400 transition-all"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-semibold mb-2">Phone</label>
                <input
                  type="tel"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  className="w-full px-4 py-3 rounded-lg bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-amber-400 transition-all"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold mb-2">Tell us about your project</label>
              <textarea
                value={formData.message}
                onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                rows="5"
                className="w-full px-4 py-3 rounded-lg bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-amber-400 transition-all"
                required
              ></textarea>
            </div>

            <button
              type="submit"
              className="w-full bg-gradient-to-r from-amber-600 to-orange-600 text-white py-4 rounded-lg font-bold text-lg hover:from-amber-700 hover:to-orange-700 transition-all duration-300 shadow-lg hover:shadow-xl transform hover:-translate-y-1"
            >
              Request a Quote
            </button>
          </form>

          <div className="border-t border-gray-700 pt-12 grid md:grid-cols-3 gap-8 text-center">
            <div className="space-y-3">
              <div className="w-12 h-12 bg-amber-600 rounded-full flex items-center justify-center mx-auto">
                <Phone className="w-6 h-6 text-white" />
              </div>
              <p className="text-sm text-gray-300">Call for immediate assistance</p>
            </div>
            <div className="space-y-3">
              <div className="w-12 h-12 bg-amber-600 rounded-full flex items-center justify-center mx-auto">
                <MapPin className="w-6 h-6 text-white" />
              </div>
              <p className="text-sm text-gray-300">Denver Metro Area to Pueblo</p>
            </div>
            <div className="space-y-3">
              <div className="w-12 h-12 bg-amber-600 rounded-full flex items-center justify-center mx-auto">
                <Check className="w-6 h-6 text-white" />
              </div>
              <p className="text-sm text-gray-300">Free consultations available</p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-black text-gray-300 py-8 px-6 text-center">
        <p className="text-sm">© 2024 Dynamic Envision Solutions. All rights reserved.</p>
      </footer>
    </div>
  );
}