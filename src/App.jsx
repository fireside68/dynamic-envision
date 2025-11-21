import React, { useState } from 'react';
import { ChevronDown, MapPin, Phone, Mail, Star, Check } from 'lucide-react';
import fullLogo from './assets/logos/fulllogo.png';
import transparentLogo from './assets/logos/grayscale_transparent.png';

export default function DynamicEnvision() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    message: ''
  });

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
            <span className="text-lg font-bold text-gray-900">Dynamic Envision</span>
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
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-20 right-20 w-96 h-96 bg-gray-400 rounded-full mix-blend-multiply filter blur-3xl"></div>
          <div className="absolute -bottom-8 left-20 w-96 h-96 bg-gray-300 rounded-full mix-blend-multiply filter blur-3xl"></div>
        </div>

        <div className="relative min-h-screen flex flex-col lg:flex-row items-center justify-center px-6 py-20 max-w-7xl mx-auto">
          {/* Logo Side */}
          <div className="lg:w-1/2 flex items-center justify-center mb-12 lg:mb-0">
            <div className="relative">
              <img 
                src={transparentLogo} 
                alt="Dynamic Envision Solutions" 
                className="w-72 h-72 lg:w-96 lg:h-96 opacity-90 hover:opacity-100 transition-opacity duration-500"
              />
              {/* Subtle earth tone glow behind logo */}
              <div className="absolute inset-0 bg-gradient-radial from-amber-600/10 via-orange-600/5 to-transparent rounded-full blur-3xl transform scale-150"></div>
            </div>
          </div>

          {/* Content Side */}
          <div className="lg:w-1/2 text-center lg:text-left space-y-8">
            <div>
              <h1 className="text-5xl lg:text-7xl font-bold text-gray-900 mb-6 leading-tight">
                Premium Windows &{' '}
                <span className="text-transparent bg-gradient-to-r from-amber-700 to-orange-700 bg-clip-text">
                  Doors
                </span>
              </h1>
              <div className="w-24 h-1 bg-gradient-to-r from-amber-700 to-orange-700 mx-auto lg:mx-0 mb-6"></div>
              <p className="text-xl lg:text-2xl text-gray-600 max-w-xl mx-auto lg:mx-0">
                15 years of craftsmanship in the Denver metro area. We don't just replace windows—we transform your home's comfort and aesthetic.
              </p>
            </div>

            <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
              <button className="bg-gray-900 text-white px-8 py-4 rounded-lg font-semibold hover:bg-gray-800 transition-all duration-300 shadow-lg hover:shadow-xl transform hover:-translate-y-1">
                Get a Quote
              </button>
              <button className="border-2 border-gray-900 text-gray-900 px-8 py-4 rounded-lg font-semibold hover:bg-gray-50 transition-all duration-300">
                View Our Work
              </button>
            </div>

            <div className="flex flex-col sm:flex-row gap-8 text-gray-700 font-semibold justify-center lg:justify-start">
              <div className="flex items-center gap-3 justify-center lg:justify-start">
                <div className="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center">
                  <MapPin className="w-5 h-5 text-amber-700" />
                </div>
                <span>Denver to Pueblo</span>
              </div>
              <div className="flex items-center gap-3 justify-center lg:justify-start">
                <div className="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center">
                  <Phone className="w-5 h-5 text-amber-700" />
                </div>
                <span>Free Consultations</span>
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
            <h2 className="text-4xl lg:text-5xl font-bold text-gray-900 mb-4">Our Work</h2>
            <div className="w-24 h-1 bg-gradient-to-r from-amber-700 to-orange-700 mx-auto mb-6"></div>
            <p className="text-lg text-gray-600">Every project tells a story of quality and attention to detail</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[1, 2, 3, 4, 5, 6].map((item) => (
              <div key={item} className="group relative overflow-hidden rounded-xl shadow-lg hover:shadow-2xl transition-all duration-300 h-72 bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center cursor-pointer transform hover:-translate-y-2">
                <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-all duration-300"></div>
                <div className="text-center z-10 group-hover:scale-105 transition-transform duration-300">
                  <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg">
                    <div className="w-8 h-8 bg-gradient-to-r from-amber-700 to-orange-700 rounded"></div>
                  </div>
                  <p className="text-gray-800 font-semibold mb-2">Project {item}</p>
                  <p className="text-sm text-gray-600">[Photo placeholder]</p>
                </div>
              </div>
            ))}
          </div>

          <div className="text-center mt-12">
            <p className="text-gray-600 italic mb-4">Ready to upload your project photos? Contact us to add more to your portfolio.</p>
          </div>
        </div>
      </section>

      {/* About Section */}
      <section id="about" className="py-20 px-6 bg-white">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl lg:text-5xl font-bold text-gray-900 mb-4">Why Dynamic Envision?</h2>
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