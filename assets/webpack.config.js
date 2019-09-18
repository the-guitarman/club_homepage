const path = require('path');
const glob = require('glob');
const webpack = require("webpack");
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const devMode = process.env.NODE_ENV !== 'production';

module.exports = (env, options) => ({
  //watch: devMode,
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: devMode }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  externals: {
    // require("jquery") is external and available
    //  on the global var jQuery
    //"jquery": "jQuery",
    // "moment": "moment"
  },
  entry: {
    app: ['./js/app.js', './css/app.less']
  },
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js')
  },
  devtool: devMode ? 'source-map' : undefined,
  module: {
    rules: [
      {
        // move es6 to es5
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        // move less to css
        test: /\.less$/,
        use: [
          // {
          //   loader: 'style-loader', // creates style nodes from JS strings for direct use in html > head
          // },
          MiniCssExtractPlugin.loader,
          {
            loader: 'css-loader', // translates CSS into CommonJS
            options: {
              sourceMap: devMode
            }
          },
          {
            loader: 'less-loader', // compile Less to CSS
            options: {
              sourceMap: devMode
            }
          }
        ]
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader']
      },
      // {
      //   test: /\.(png|jp(e)?g|gif|svg)$/,
      //   use: ['file-loader']
      // },
      {
        test: /\.(woff(2)?|eot|ttf|svg)$/,
        use: [{
          loader: 'file-loader',
          options: {
            name: '[name].[ext]',
            outputPath: '../fonts/'
          }
        }]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({filename: '../css/app.css'}),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }]),
    new webpack.ProvidePlugin({ jQuery: 'jquery', $: 'jquery' })
  ]
});
